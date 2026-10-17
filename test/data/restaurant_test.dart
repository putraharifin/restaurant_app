import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_app/data/models/restaurant.dart';

void main() {
  group('Restaurant', () {
    test('fromJson parses the API response', () {
      final restaurant = Restaurant.fromJson({
        'id': 'rqdv5juczeskfw1e867',
        'name': 'Melting Pot',
        'description': 'Lorem ipsum dolor sit amet.',
        'pictureId': '14',
        'city': 'Medan',
        'rating': 4.2,
      });

      expect(restaurant.id, 'rqdv5juczeskfw1e867');
      expect(restaurant.name, 'Melting Pot');
      expect(restaurant.city, 'Medan');
      expect(restaurant.rating, 4.2);
    });

    test('fromJson accepts an integer rating from the API', () {
      final restaurant = Restaurant.fromJson({
        'id': 's1knt6za9kkfw1e867',
        'name': 'Kafe Kita',
        'description': 'Quisque rutrum.',
        'pictureId': '25',
        'city': 'Gorontalo',
        'rating': 4,
      });

      expect(restaurant.rating, 4.0);
    });

    test('survives the toMap and JSON round trip used by notifications', () {
      const original = Restaurant(
        id: 'rqdv5juczeskfw1e867',
        name: 'Melting Pot',
        description: 'Lorem ipsum dolor sit amet.',
        pictureId: '14',
        city: 'Medan',
        rating: 4.2,
      );

      final payload = jsonEncode(original.toMap());
      final restored = Restaurant.fromJson(
        jsonDecode(payload) as Map<String, dynamic>,
      );

      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.description, original.description);
      expect(restored.pictureId, original.pictureId);
      expect(restored.city, original.city);
      expect(restored.rating, original.rating);
    });
  });
}