import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/providers/restaurant_list_provider.dart';
import 'package:restaurant_app/static/result_state.dart';
import 'package:restaurant_app/ui/screens/restaurant_detail_screen.dart';
import 'package:restaurant_app/ui/widgets/empty_view.dart';
import 'package:restaurant_app/ui/widgets/error_view.dart';
import 'package:restaurant_app/ui/widgets/loading_indicator.dart';
import 'package:restaurant_app/ui/widgets/restaurant_card.dart';
import 'package:restaurant_app/ui/widgets/restaurant_search_field.dart';
import 'package:restaurant_app/ui/widgets/screen_header.dart';

class RestaurantListScreen extends StatelessWidget {
  const RestaurantListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ScreenHeader(
              title: 'Restaurant',
              subtitle: 'Recommendation restaurant for you!',
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: RestaurantSearchField(
                onChanged: context.read<RestaurantListProvider>().onQueryChanged,
              ),
            ),
            Expanded(
              child: Consumer<RestaurantListProvider>(
                builder: (context, provider, _) {
                  return switch (provider.state) {
                    InitialState() || LoadingState() => const LoadingIndicator(),
                    LoadedState(:final data) => ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          final restaurant = data[index];
                          final heroTag = 'list-${restaurant.id}';
                          return RestaurantCard(
                            restaurant: restaurant,
                            heroTag: heroTag,
                            onTap: () => RestaurantDetailScreen.open(
                              context,
                              restaurant,
                              heroTag,
                            ),
                          );
                        },
                      ),
                    NoDataState(:final message) => EmptyView(message: message),
                    ErrorState(:final message) => ErrorView(
                        message: message,
                        onRetry: provider.reload,
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