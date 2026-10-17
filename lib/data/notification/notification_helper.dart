import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:restaurant_app/data/models/restaurant.dart';

class NotificationHelper {
  NotificationHelper([FlutterLocalNotificationsPlugin? plugin])
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  static const String _channelId = 'daily_restaurant_reminder';
  static const String _channelName = 'Daily Restaurant Reminder';
  static const int _notificationId = 1;

  final FlutterLocalNotificationsPlugin _plugin;

  Future<void> initialize({void Function(String payload)? onSelect}) async {
    await _plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload != null) onSelect?.call(payload);
      },
    );
  }

  Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    return await android?.requestNotificationsPermission() ?? true;
  }

  Future<String?> launchPayload() async {
    final details = await _plugin.getNotificationAppLaunchDetails();
    if (details?.didNotificationLaunchApp != true) return null;
    return details?.notificationResponse?.payload;
  }

  Future<void> showRestaurantNotification(Restaurant restaurant) {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: 'Rekomendasi restoran harian pukul 11.00',
        importance: Importance.high,
        priority: Priority.high,
      ),
    );

    return _plugin.show(
      _notificationId,
      restaurant.name,
      'Recommendation restaurant for you!',
      details,
      payload: jsonEncode(restaurant.toMap()),
    );
  }
}