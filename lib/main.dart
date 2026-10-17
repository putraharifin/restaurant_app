import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/data/api/api_service.dart';
import 'package:restaurant_app/data/background/background_service.dart';
import 'package:restaurant_app/data/database/database_helper.dart';
import 'package:restaurant_app/data/notification/notification_helper.dart';
import 'package:restaurant_app/data/preferences/preferences_helper.dart';
import 'package:restaurant_app/providers/favorite_provider.dart';
import 'package:restaurant_app/providers/restaurant_list_provider.dart';
import 'package:restaurant_app/providers/settings_provider.dart';
import 'package:restaurant_app/static/app_theme.dart';
import 'package:restaurant_app/ui/app_navigator.dart';
import 'package:restaurant_app/ui/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();
  await BackgroundService.initialize();

  final notificationHelper = NotificationHelper();
  await notificationHelper.initialize(
    onSelect: AppNavigator.openRestaurantFromPayload,
  );
  final launchPayload = await notificationHelper.launchPayload();

  runApp(
    MultiProvider(
      providers: [
        Provider<ApiService>(
          create: (_) => ApiService(),
          dispose: (_, service) => service.dispose(),
        ),
        Provider<PreferencesHelper>.value(
          value: PreferencesHelper(preferences),
        ),
        Provider<NotificationHelper>.value(value: notificationHelper),
        Provider<BackgroundService>(create: (_) => BackgroundService()),
        ChangeNotifierProvider<SettingsProvider>(
          create: (context) => SettingsProvider(
            context.read<PreferencesHelper>(),
            context.read<BackgroundService>(),
            context.read<NotificationHelper>(),
          ),
        ),
        Provider<DatabaseHelper>(create: (_) => DatabaseHelper()),
        ChangeNotifierProvider<FavoriteProvider>(
          create: (context) => FavoriteProvider(context.read<DatabaseHelper>()),
        ),
        ChangeNotifierProvider<RestaurantListProvider>(
          create: (context) =>
              RestaurantListProvider(context.read<ApiService>()),
        ),
      ],
      child: const RestaurantApp(),
    ),
  );

  if (launchPayload != null) {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => AppNavigator.openRestaurantFromPayload(launchPayload),
    );
  }
}

class RestaurantApp extends StatelessWidget {
  const RestaurantApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = context.select<SettingsProvider, ThemeMode>(
      (settings) => settings.themeMode,
    );

    return MaterialApp(
      title: 'Restaurant App',
      navigatorKey: AppNavigator.key,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      home: const HomeScreen(),
    );
  }
}
