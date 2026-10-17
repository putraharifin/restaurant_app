import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/providers/favorite_provider.dart';
import 'package:restaurant_app/static/result_state.dart';
import 'package:restaurant_app/ui/screens/restaurant_detail_screen.dart';
import 'package:restaurant_app/ui/widgets/empty_view.dart';
import 'package:restaurant_app/ui/widgets/error_view.dart';
import 'package:restaurant_app/ui/widgets/favorite_button.dart';
import 'package:restaurant_app/ui/widgets/loading_indicator.dart';
import 'package:restaurant_app/ui/widgets/restaurant_card.dart';
import 'package:restaurant_app/ui/widgets/screen_header.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ScreenHeader(
              title: 'Favorites',
              subtitle: 'Your favorite restaurants',
            ),
            Expanded(
              child: Consumer<FavoriteProvider>(
                builder: (context, provider, _) {
                  return switch (provider.state) {
                    InitialState() || LoadingState() => const LoadingIndicator(),
                    LoadedState(:final data) => ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          final restaurant = data[index];
                          final heroTag = 'favorite-${restaurant.id}';
                          return RestaurantCard(
                            restaurant: restaurant,
                            heroTag: heroTag,
                            trailing: FavoriteButton(restaurant: restaurant),
                            onTap: () => RestaurantDetailScreen.open(
                              context,
                              restaurant,
                              heroTag,
                            ),
                          );
                        },
                      ),
                    NoDataState(:final message) => EmptyView(
                        message: message,
                        icon: Icons.favorite_border,
                      ),
                    ErrorState(:final message) => ErrorView(
                        message: message,
                        onRetry: provider.loadFavorites,
                      ),
                  };
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}