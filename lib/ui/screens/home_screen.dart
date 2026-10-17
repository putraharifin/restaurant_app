import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/providers/navigation_provider.dart';
import 'package:restaurant_app/ui/screens/favorite_screen.dart';
import 'package:restaurant_app/ui/screens/restaurant_list_screen.dart';
import 'package:restaurant_app/ui/screens/settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const List<Widget> _pages = [
    RestaurantListScreen(),
    FavoriteScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<NavigationProvider>(
      create: (_) => NavigationProvider(),
      child: Consumer<NavigationProvider>(
        builder: (context, navigation, _) {
          return Scaffold(
            body: IndexedStack(index: navigation.index, children: _pages),
            bottomNavigationBar: NavigationBar(
              selectedIndex: navigation.index,
              onDestinationSelected: navigation.select,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.restaurant_outlined),
                  selectedIcon: Icon(Icons.restaurant),
                  label: 'Restaurant',
                ),
                NavigationDestination(
                  icon: Icon(Icons.favorite_border),
                  selectedIcon: Icon(Icons.favorite),
                  label: 'Favorites',
                ),
                NavigationDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings),
                  label: 'Setting',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}