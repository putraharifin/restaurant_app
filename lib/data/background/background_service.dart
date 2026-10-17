import 'dart:math';

import 'package:restaurant_app/data/api/api_exception.dart';
import 'package:restaurant_app/data/api/api_service.dart';
import 'package:restaurant_app/data/notification/notification_helper.dart';
import 'package:workmanager/workmanager.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task != BackgroundService.taskName) return true;

    final apiService = ApiService();
    try {
      final restaurants = await apiService.getRestaurants();
      if (restaurants.isEmpty) return true;

      final restaurant = restaurants[Random().nextInt(restaurants.length)];
      final notificationHelper = NotificationHelper();
      await notificationHelper.initialize();
      await notificationHelper.showRestaurantNotification(restaurant);
      return true;
    } on ApiException {
      return false;
    } finally {
      apiService.dispose();
    }
  });
}

class BackgroundService {
  static const String taskName = 'daily_restaurant_reminder_task';
  static const String _uniqueName = 'daily_restaurant_reminder';
  static const int _reminderHour = 11;

  static Future<void> initialize() {
    return Workmanager().initialize(callbackDispatcher);
  }

  static Duration delayUntilNextReminder(DateTime now) {
    var next = DateTime(now.year, now.month, now.day, _reminderHour);
    if (!next.isAfter(now)) {
      next = DateTime(now.year, now.month, now.day + 1, _reminderHour);
    }
    return next.difference(now);
  }

  Future<void> scheduleDailyReminder() {
    return Workmanager().registerPeriodicTask(
      _uniqueName,
      taskName,
      frequency: const Duration(hours: 24),
      initialDelay: delayUntilNextReminder(DateTime.now()),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
      constraints: Constraints(networkType: NetworkType.connected),
    );
  }

  Future<void> cancelDailyReminder() {
    return Workmanager().cancelByUniqueName(_uniqueName);
  }
}