import 'package:flutter/material.dart';
import 'package:restaurant_app/data/models/restaurant_detail.dart';
import 'package:restaurant_app/ui/widgets/menu_section.dart';
import 'package:restaurant_app/ui/widgets/review_card.dart';
import 'package:restaurant_app/ui/widgets/review_form.dart';

class RestaurantDetailContent extends StatelessWidget {
  const RestaurantDetailContent({super.key, required this.detail});

  final RestaurantDetail detail;

  void _showFullDescription(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                detail.name,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: SingleChildScrollView(child: Text(detail.description)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w600,
    );

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  detail.name,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.star_rounded, color: Colors.amber),
              const SizedBox(width: 4),
              Text(
                detail.rating.toStringAsFixed(1),
                style: theme.textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _InfoRow(icon: Icons.location_city_outlined, text: detail.city),
          const SizedBox(height: 6),
          _InfoRow(icon: Icons.place_outlined, text: detail.address),
          if (detail.categories.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: detail.categories
                  .map((category) => Chip(label: Text(category)))
                  .toList(),
            ),
          ],
          const SizedBox(height: 20),
          Text('Deskripsi', style: titleStyle),
          const SizedBox(height: 8),
          Text(
            detail.description,
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium,
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => _showFullDescription(context),
              child: const Text('Baca selengkapnya'),
            ),
          ),
          const SizedBox(height: 12),
          MenuSection(
            title: 'Menu Makanan',
            items: detail.menus.foods,
            icon: Icons.restaurant_rounded,
          ),
          MenuSection(
            title: 'Menu Minuman',
            items: detail.menus.drinks,
            icon: Icons.local_cafe_rounded,
          ),
          Text(
            'Ulasan Pelanggan (${detail.customerReviews.length})',
            style: titleStyle,
          ),
          const SizedBox(height: 12),
          const ReviewForm(),
          ...detail.customerReviews.reversed.map(
            (review) => ReviewCard(review: review),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.secondary),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
      ],
    );
  }
}
