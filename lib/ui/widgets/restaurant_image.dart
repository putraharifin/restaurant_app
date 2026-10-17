import 'package:flutter/material.dart';
import 'package:restaurant_app/data/api/api_service.dart';

class RestaurantImage extends StatelessWidget {
  const RestaurantImage({
    super.key,
    required this.pictureId,
    required this.size,
  });

  final String pictureId;
  final ImageSize size;

  @override
  Widget build(BuildContext context) {
    final background = Theme.of(context).colorScheme.surfaceContainerHighest;

    return Image.network(
      ApiService.imageUrl(pictureId, size),
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return ColoredBox(
          color: background,
          child: const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return ColoredBox(
          color: background,
          child: const Center(child: Icon(Icons.broken_image_outlined)),
        );
      },
    );
  }
}
