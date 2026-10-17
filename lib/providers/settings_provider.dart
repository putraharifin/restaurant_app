import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:restaurant_app/data/background/background_service.dart';
import 'package:restaurant_app/data/notification/notification_helper.dart';
import 'package:restaurant_app/data/preferences/preferences_helper.dart';

enum ReminderToggleResult { success, permissionDenied, failed }

class SettingsProvider extends ChangeNotifier {
  SettingsProvider(
    this._helper,
    this._backgroundService,
    this._notificationHelper,
  )   : _isDarkTheme = _helper.isDarkTheme,
        _isDailyReminderActive = _helper.isDailyReminderActive;

  final PreferencesHelper _helper;
  final BackgroundService _backgroundService;
  final NotificationHelper _notificationHelper;

  bool _isDarkTheme;
  bool _isDailyReminderActive;

  bool get isDarkTheme => _isDarkTheme;

  bool get isDailyReminderActive => _isDailyReminderActive;

  ThemeMode get themeMode => _isDarkTheme ? ThemeMode.dark : ThemeMode.light;

  Future<void> setDarkTheme(bool value) async {
    if (_isDarkTheme == value) return;
    _isDarkTheme = value;
    notifyListeners();
    await _helper.setDarkTheme(value);
  }

  Future<ReminderToggleResult> setDailyReminder(bool value) async {
    if (_isDailyReminderActive == value) return ReminderToggleResult.success;

    try {
      if (value) {
        final granted = await _notificationHelper.requestPermission();
        if (!granted) return ReminderToggleResult.permissionDenied;
        await _backgroundService.scheduleDailyReminder();
      } else {
        await _backgroundService.cancelDailyReminder();
      }
    } on PlatformException {
      return ReminderToggleResult.failed;
    }

    _isDailyReminderActive = value;
    notifyListeners();
    await _helper.setDailyReminderActive(value);
    return ReminderToggleResult.success;
  }
}