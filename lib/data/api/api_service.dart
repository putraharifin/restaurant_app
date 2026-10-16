import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:restaurant_app/data/api/api_exception.dart';
import 'package:restaurant_app/data/models/customer_review.dart';
import 'package:restaurant_app/data/models/restaurant.dart';
import 'package:restaurant_app/data/models/restaurant_detail.dart';

enum ImageSize { small, medium, large }

class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  static const String _baseUrl = 'https://restaurant-api.dicoding.dev';
  static const Duration _timeout = Duration(seconds: 15);

  final http.Client _client;

  static String imageUrl(String pictureId, ImageSize size) {
    return '$_baseUrl/images/${size.name}/$pictureId';
  }

  Future<List<Restaurant>> getRestaurants() {
    return _guard(() async {
      final json = await _get('/list');
      return _parseRestaurants(json['restaurants']);
    });
  }

  Future<List<Restaurant>> searchRestaurants(String query) {
    return _guard(() async {
      final json = await _get('/search', {'q': query});
      return _parseRestaurants(json['restaurants']);
    });
  }

  Future<RestaurantDetail> getRestaurantDetail(String id) {
    return _guard(() async {
      final json = await _get('/detail/$id');
      return RestaurantDetail.fromJson(
        json['restaurant'] as Map<String, dynamic>,
      );
    });
  }

  Future<List<CustomerReview>> addReview({
    required String id,
    required String name,
    required String review,
  }) {
    return _guard(() async {
      final response = await _client.post(
        Uri.parse('$_baseUrl/review'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id': id, 'name': name, 'review': review}),
      );
      final json = _decode(response);
      return (json['customerReviews'] as List<dynamic>)
          .map((item) => CustomerReview.fromJson(item as Map<String, dynamic>))
          .toList();
    });
  }

  void dispose() => _client.close();

  Future<Map<String, dynamic>> _get(
    String path, [
    Map<String, String>? queryParameters,
  ]) async {
    final uri = Uri.parse('$_baseUrl$path').replace(
      queryParameters: queryParameters,
    );
    return _decode(await _client.get(uri));
  }

  Map<String, dynamic> _decode(http.Response response) {
    final isSuccess = response.statusCode >= 200 && response.statusCode < 300;
    if (!isSuccess) {
      throw ApiException(
        'Server sedang bermasalah (kode ${response.statusCode}). '
        'Silakan coba lagi nanti.',
      );
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (body['error'] == true) {
      throw ApiException(
        body['message'] as String? ?? 'Terjadi kesalahan pada server.',
      );
    }
    return body;
  }

  List<Restaurant> _parseRestaurants(Object? items) {
    return (items as List<dynamic>)
        .map((item) => Restaurant.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action().timeout(_timeout);
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw const ApiException(
        'Koneksi terlalu lama. Periksa jaringan Anda lalu coba lagi.',
      );
    } on http.ClientException {
      throw const ApiException(
        'Tidak dapat terhubung ke internet. Periksa koneksi Anda.',
      );
    } catch (_) {
      throw const ApiException(
        'Terjadi kesalahan saat memproses data. Silakan coba lagi.',
      );
    }
  }
}
