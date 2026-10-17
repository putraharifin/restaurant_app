import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:restaurant_app/data/api/api_exception.dart';
import 'package:restaurant_app/data/api/api_service.dart';
import 'package:restaurant_app/data/models/restaurant.dart';
import 'package:restaurant_app/static/result_state.dart';

class RestaurantListProvider extends ChangeNotifier {
  RestaurantListProvider(this._apiService) {
    _load('');
  }

  final ApiService _apiService;

  ResultState<List<Restaurant>> _state = const InitialState();
  Timer? _debounce;
  String _query = '';
  int _requestId = 0;
  bool _isDisposed = false;

  ResultState<List<Restaurant>> get state => _state;

  void onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 500),
      () => _load(value.trim()),
    );
  }

  Future<void> reload() => _load(_query);

  Future<void> _load(String query) async {
    _query = query;
    final requestId = ++_requestId;
    _state = const LoadingState();
    notifyListeners();

    ResultState<List<Restaurant>> result;
    try {
      final restaurants = query.isEmpty
          ? await _apiService.getRestaurants()
          : await _apiService.searchRestaurants(query);
      result = restaurants.isEmpty
          ? NoDataState(
              query.isEmpty
                  ? 'Belum ada restoran yang tersedia.'
                  : 'Restoran dengan kata kunci "$query" tidak ditemukan.',
            )
          : LoadedState(restaurants);
    } on ApiException catch (e) {
      result = ErrorState(e.message);
    }

    if (_isDisposed || requestId != _requestId) return;
    _state = result;
    notifyListeners();
  }

  @override
  void notifyListeners() {
    if (!_isDisposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _debounce?.cancel();
    super.dispose();
  }
}
