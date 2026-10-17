import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/data/api/api_service.dart';
import 'package:restaurant_app/data/models/restaurant.dart';
import 'package:restaurant_app/providers/restaurant_detail_provider.dart';
import 'package:restaurant_app/static/result_state.dart';
import 'package:restaurant_app/ui/widgets/empty_view.dart';
import 'package:restaurant_app/ui/widgets/error_view.dart';
import 'package:restaurant_app/ui/widgets/loading_indicator.dart';
import 'package:restaurant_app/ui/widgets/restaurant_detail_content.dart';
import 'package:restaurant_app/ui/widgets/restaurant_image.dart';

class RestaurantDetailScreen extends StatelessWidget {
  const RestaurantDetailScreen({super.key, required this.restaurant});

  final Restaurant restaurant;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<RestaurantDetailProvider>(
      create: (context) => RestaurantDetailProvider(
        context.read<ApiService>(),
        restaurant.id,
      ),
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              _Header(restaurant: restaurant),
              Consumer<RestaurantDetailProvider>(
                builder: (context, provider, _) {
                  return switch (provider.state) {
                    InitialState() || LoadingState() => const LoadingIndicator(),
                    LoadedState(:final data) =>
                      RestaurantDetailContent(detail: data),
                    NoDataState(:final message) => EmptyView(message: message),
                    ErrorState(:final message) => ErrorView(
                        message: message,
                        onRetry: provider.fetchDetail,
                      ),
                  };
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.restaurant});

  final Restaurant restaurant;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        Hero(
          tag: restaurant.id,
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(28),
            ),
            child: SizedBox(
              height: 260,
              width: double.infinity,
              child: RestaurantImage(
                pictureId: restaurant.pictureId,
                size: ImageSize.large,
              ),
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: CircleAvatar(
                backgroundColor: scheme.surface.withValues(alpha: 0.85),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  color: scheme.onSurface,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
