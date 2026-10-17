import 'package:flutter/foundation.dart';
import 'package:restaurant_app/data/api/api_exception.dart';
import 'package:restaurant_app/data/api/api_service.dart';
import 'package:restaurant_app/data/models/restaurant_detail.dart';
import 'package:restaurant_app/static/result_state.dart';

class RestaurantDetailProvider extends ChangeNotifier {
  RestaurantDetailProvider(this._apiService, this._restaurantId) {
    fetchDetail();
  }

  final ApiService _apiService;
  final String _restaurantId;

  ResultState<RestaurantDetail> _state = const InitialState();
  bool _isSubmitting = false;
  bool _isDisposed = false;

  ResultState<RestaurantDetail> get state => _state;

  bool get isSubmitting => _isSubmitting;

  Future<void> fetchDetail() async {
    _state = const LoadingState();
    notifyListeners();

    try {
      _state = LoadedState(
        await _apiService.getRestaurantDetail(_restaurantId),
      );
    } on ApiException catch (e) {
      _state = ErrorState(e.message);
    }
    notifyListeners();
  }

  Future<String?> submitReview({
    required String name,
    required String review,
  }) async {
    _isSubmitting = true;
    notifyListeners();

    try {
      final reviews = await _apiService.addReview(
        id: _restaurantId,
        name: name,
        review: review,
      );
      final current = _state;
      if (current is LoadedState<RestaurantDetail>) {
        _state = LoadedState(current.data.copyWith(customerReviews: reviews));
      }
      return null;
    } on ApiException catch (e) {
      return e.message;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  @override
  void notifyListeners() {
    if (!_isDisposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
