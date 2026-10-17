import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:restaurant_app/data/api/api_exception.dart';
import 'package:restaurant_app/data/api/api_service.dart';
import 'package:restaurant_app/data/models/restaurant.dart';
import 'package:restaurant_app/providers/restaurant_list_provider.dart';
import 'package:restaurant_app/static/result_state.dart';

class MockApiService extends Mock implements ApiService {}

const _meltingPot = Restaurant(
  id: 'rqdv5juczeskfw1e867',
  name: 'Melting Pot',
  description: 'Lorem ipsum dolor sit amet.',
  pictureId: '14',
  city: 'Medan',
  rating: 4.2,
);

const _kafeKita = Restaurant(
  id: 's1knt6za9kkfw1e867',
  name: 'Kafe Kita',
  description: 'Quisque rutrum.',
  pictureId: '25',
  city: 'Gorontalo',
  rating: 4,
);

const _noConnection = 'Tidak dapat terhubung ke internet.';

Future<void> _waitForDebounce() async {
  await Future<void>.delayed(const Duration(milliseconds: 600));
  await pumpEventQueue();
}

void main() {
  late MockApiService apiService;

  setUp(() {
    apiService = MockApiService();
  });

  RestaurantListProvider createProvider() {
    final provider = RestaurantListProvider(apiService);
    addTearDown(provider.dispose);
    return provider;
  }

  group('RestaurantListProvider', () {
    test('initial state is loading right after the provider is created',
        () async {
      final pending = Completer<List<Restaurant>>();
      when(() => apiService.getRestaurants()).thenAnswer((_) => pending.future);

      final provider = createProvider();

      expect(provider.state, isA<LoadingState<List<Restaurant>>>());

      pending.complete([_meltingPot]);
      await pumpEventQueue();
    });

    test('returns a list of restaurants when the API fetch succeeds', () async {
      when(() => apiService.getRestaurants())
          .thenAnswer((_) async => [_meltingPot, _kafeKita]);

      final provider = createProvider();
      await pumpEventQueue();

      expect(
        provider.state,
        isA<LoadedState<List<Restaurant>>>().having(
          (state) => state.data,
          'data',
          [_meltingPot, _kafeKita],
        ),
      );
      verify(() => apiService.getRestaurants()).called(1);
    });

    test('returns an error state when the API fetch fails', () async {
      when(() => apiService.getRestaurants())
          .thenAnswer((_) async => throw const ApiException(_noConnection));

      final provider = createProvider();
      await pumpEventQueue();

      expect(
        provider.state,
        isA<ErrorState<List<Restaurant>>>().having(
          (state) => state.message,
          'message',
          _noConnection,
        ),
      );
    });

    test('returns no data state when the API returns an empty list', () async {
      when(() => apiService.getRestaurants()).thenAnswer((_) async => []);

      final provider = createProvider();
      await pumpEventQueue();

      expect(provider.state, isA<NoDataState<List<Restaurant>>>());
    });

    test('reload recovers from an error state', () async {
      when(() => apiService.getRestaurants())
          .thenAnswer((_) async => throw const ApiException(_noConnection));
      final provider = createProvider();
      await pumpEventQueue();
      expect(provider.state, isA<ErrorState<List<Restaurant>>>());

      when(() => apiService.getRestaurants())
          .thenAnswer((_) async => [_meltingPot]);
      await provider.reload();

      expect(provider.state, isA<LoadedState<List<Restaurant>>>());
    });

    test('ignores a stale response that arrives after a newer one', () async {
      final slowRequest = Completer<List<Restaurant>>();
      when(() => apiService.getRestaurants())
          .thenAnswer((_) => slowRequest.future);
      final provider = createProvider();

      when(() => apiService.getRestaurants())
          .thenAnswer((_) async => [_meltingPot]);
      await provider.reload();

      slowRequest.complete([_kafeKita]);
      await pumpEventQueue();

      expect(
        provider.state,
        isA<LoadedState<List<Restaurant>>>().having(
          (state) => state.data,
          'data',
          [_meltingPot],
        ),
      );
    });

    group('search', () {
      setUp(() {
        when(() => apiService.getRestaurants())
            .thenAnswer((_) async => [_meltingPot, _kafeKita]);
      });

      test('returns search results from the search endpoint', () async {
        when(() => apiService.searchRestaurants('kafe'))
            .thenAnswer((_) async => [_kafeKita]);
        final provider = createProvider();
        await pumpEventQueue();

        provider.onQueryChanged('kafe');
        await _waitForDebounce();

        expect(
          provider.state,
          isA<LoadedState<List<Restaurant>>>().having(
            (state) => state.data,
            'data',
            [_kafeKita],
          ),
        );
      });

      test('returns no data state when nothing matches the keyword', () async {
        when(() => apiService.searchRestaurants('xyz'))
            .thenAnswer((_) async => []);
        final provider = createProvider();
        await pumpEventQueue();

        provider.onQueryChanged('xyz');
        await _waitForDebounce();

        expect(
          provider.state,
          isA<NoDataState<List<Restaurant>>>().having(
            (state) => state.message,
            'message',
            contains('xyz'),
          ),
        );
      });

      test('debounces rapid typing into a single trimmed request', () async {
        when(() => apiService.searchRestaurants('cafe'))
            .thenAnswer((_) async => [_kafeKita]);
        final provider = createProvider();
        await pumpEventQueue();

        provider
          ..onQueryChanged('c')
          ..onQueryChanged('ca')
          ..onQueryChanged('  cafe ');
        await _waitForDebounce();

        verify(() => apiService.searchRestaurants('cafe')).called(1);
        verifyNever(() => apiService.searchRestaurants('c'));
        verifyNever(() => apiService.searchRestaurants('ca'));
      });

      test('clearing the keyword loads the full list again', () async {
        when(() => apiService.searchRestaurants('kafe'))
            .thenAnswer((_) async => [_kafeKita]);
        final provider = createProvider();
        await pumpEventQueue();

        provider.onQueryChanged('kafe');
        await _waitForDebounce();
        provider.onQueryChanged('');
        await _waitForDebounce();

        verify(() => apiService.getRestaurants()).called(2);
        expect(
          provider.state,
          isA<LoadedState<List<Restaurant>>>().having(
            (state) => state.data.length,
            'length',
            2,
          ),
        );
      });
    });
  });
}