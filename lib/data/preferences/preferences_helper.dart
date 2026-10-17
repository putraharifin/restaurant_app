import 'package:shared_preferences/shared_preferences.dart';

class PreferencesHelper {
  const PreferencesHelper(this._preferences);

  static const String _darkThemeKey = 'dark_theme';
  static const String _dailyReminderKey = 'daily_reminder';

  final SharedPreferences _preferences;

  bool get isDarkTheme => _preferences.getBool(_darkThemeKey) ?? false;

  bool get isDailyReminderActive =>
      _preferences.getBool(_dailyReminderKey) ?? false;

  Future<void> setDarkTheme(bool value) {
    return _preferences.setBool(_darkThemeKey, value);
  }

  Future<void> setDailyReminderActive(bool value) {
    return _preferences.setBool(_dailyReminderKey, value);
  }
}