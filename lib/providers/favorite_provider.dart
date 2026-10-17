import 'package:flutter/foundation.dart';
import 'package:restaurant_app/data/database/database_helper.dart';
import 'package:restaurant_app/data/models/restaurant.dart';
import 'package:restaurant_app/static/result_state.dart';
import 'package:sqflite/sqflite.dart';

class FavoriteProvider extends ChangeNotifier {
  FavoriteProvider(this._databaseHelper) {
    loadFavorites();
  }

  final DatabaseHelper _databaseHelper;

  ResultState<List<Restaurant>> _state = const InitialState();
  Set<String> _favoriteIds = {};

  ResultState<List<Restaurant>> get state => _state;

  bool isFavorite(String id) => _favoriteIds.contains(id);

  Future<void> loadFavorites() async {
    _state = const LoadingState();
    notifyListeners();
    await _refresh();
  }

  Future<bool> toggleFavorite(Restaurant restaurant) async {
    try {
      if (isFavorite(restaurant.id)) {
        await _databaseHelper.removeFavorite(restaurant.id);
      } else {
        await _databaseHelper.insertFavorite(restaurant);
      }
    } on DatabaseException {
      return false;
    }

    await _refresh();
    return true;
  }

  Future<void> _refresh() async {
    try {
      final favorites = await _databaseHelper.getFavorites();
      _favoriteIds = favorites.map((restaurant) => restaurant.id).toSet();
      _state = favorites.isEmpty
          ? const NoDataState('Belum ada restoran favorit.')
          : LoadedState(favorites);
    } on DatabaseException {
      _state = const ErrorState('Gagal memuat restoran favorit.');
    }
    notifyListeners();
  }
}