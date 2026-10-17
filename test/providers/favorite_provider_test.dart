import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:restaurant_app/data/database/database_helper.dart';
import 'package:restaurant_app/data/models/restaurant.dart';
import 'package:restaurant_app/providers/favorite_provider.dart';
import 'package:restaurant_app/static/result_state.dart';
import 'package:sqflite/sqflite.dart';

class MockDatabaseException extends Mock implements DatabaseException {}

class FakeDatabaseHelper implements DatabaseHelper {
  final Map<String, Restaurant> _rows = {};
  DatabaseException? failure;

  void _throwIfFailing() {
    final error = failure;
    if (error != null) throw error;
  }

  @override
  Future<List<Restaurant>> getFavorites() async {
    _throwIfFailing();
    return _rows.values.toList();
  }

  @override
  Future<void> insertFavorite(Restaurant restaurant) async {
    _throwIfFailing();
    _rows[restaurant.id] = restaurant;
  }

  @override
  Future<void> removeFavorite(String id) async {
    _throwIfFailing();
    _rows.remove(id);
  }
}

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

void main() {
  late FakeDatabaseHelper database;

  setUp(() {
    database = FakeDatabaseHelper();
  });

  Future<FavoriteProvider> createProvider() async {
    final provider = FavoriteProvider(database);
    addTearDown(provider.dispose);
    await pumpEventQueue();
    return provider;
  }

  group('FavoriteProvider', () {
    test('starts in loading state while favorites are being read', () async {
      final provider = FavoriteProvider(database);
      addTearDown(provider.dispose);

      expect(provider.state, isA<LoadingState<List<Restaurant>>>());
      await pumpEventQueue();
    });

    test('shows no data state when there are no favorites', () async {
      final provider = await createProvider();

      expect(provider.state, isA<NoDataState<List<Restaurant>>>());
      expect(provider.isFavorite(_meltingPot.id), isFalse);
    });

    test('loads favorites that were saved before', () async {
      await database.insertFavorite(_meltingPot);

      final provider = await createProvider();

      expect(
        provider.state,
        isA<LoadedState<List<Restaurant>>>().having(
          (state) => state.data,
          'data',
          [_meltingPot],
        ),
      );
      expect(provider.isFavorite(_meltingPot.id), isTrue);
    });

    test('toggling an unsaved restaurant adds it to favorites', () async {
      final provider = await createProvider();

      final success = await provider.toggleFavorite(_meltingPot);

      expect(success, isTrue);
      expect(provider.isFavorite(_meltingPot.id), isTrue);
      expect(provider.state, isA<LoadedState<List<Restaurant>>>());
    });

    test('toggling a saved restaurant removes it from favorites', () async {
      await database.insertFavorite(_meltingPot);
      final provider = await createProvider();

      final success = await provider.toggleFavorite(_meltingPot);

      expect(success, isTrue);
      expect(provider.isFavorite(_meltingPot.id), isFalse);
      expect(provider.state, isA<NoDataState<List<Restaurant>>>());
    });

    test('toggling one restaurant leaves the others untouched', () async {
      await database.insertFavorite(_meltingPot);
      await database.insertFavorite(_kafeKita);
      final provider = await createProvider();

      await provider.toggleFavorite(_meltingPot);

      expect(provider.isFavorite(_meltingPot.id), isFalse);
      expect(provider.isFavorite(_kafeKita.id), isTrue);
    });

    test('notifies listeners after a toggle so the UI updates', () async {
      final provider = await createProvider();
      var notifications = 0;
      provider.addListener(() => notifications++);

      await provider.toggleFavorite(_meltingPot);

      expect(notifications, greaterThan(0));
    });

    test('keeps state unchanged and returns false when saving fails', () async {
      final provider = await createProvider();
      database.failure = MockDatabaseException();

      final success = await provider.toggleFavorite(_meltingPot);

      expect(success, isFalse);
      expect(provider.isFavorite(_meltingPot.id), isFalse);
      expect(provider.state, isA<NoDataState<List<Restaurant>>>());
    });

    test('returns an error state when favorites cannot be loaded', () async {
      database.failure = MockDatabaseException();

      final provider = await createProvider();

      expect(provider.state, isA<ErrorState<List<Restaurant>>>());
    });

    test('loadFavorites recovers after an error', () async {
      database.failure = MockDatabaseException();
      final provider = await createProvider();
      expect(provider.state, isA<ErrorState<List<Restaurant>>>());

      database
        ..failure = null
        ..insertFavorite(_kafeKita);
      await provider.loadFavorites();

      expect(provider.state, isA<LoadedState<List<Restaurant>>>());
    });
  });
}
