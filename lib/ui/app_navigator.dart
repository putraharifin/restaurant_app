import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:restaurant_app/data/models/restaurant.dart';
import 'package:restaurant_app/ui/screens/restaurant_detail_screen.dart';

abstract final class AppNavigator {
  static final GlobalKey<NavigatorState> key = GlobalKey<NavigatorState>();

  static void openRestaurantFromPayload(String payload) {
    final navigator = key.currentState;
    if (navigator == null) return;

    final Restaurant restaurant;
    try {
      restaurant = Restaurant.fromJson(
        jsonDecode(payload) as Map<String, dynamic>,
      );
    } on FormatException {
      return;
    }

    navigator.push(
      MaterialPageRoute<void>(
        builder: (_) => RestaurantDetailScreen(
          restaurant: restaurant,
          heroTag: 'notification-${restaurant.id}',
        ),
      ),
    );
  }
}