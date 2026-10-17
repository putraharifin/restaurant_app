import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/data/models/restaurant.dart';
import 'package:restaurant_app/providers/favorite_provider.dart';

class FavoriteButton extends StatelessWidget {
  const FavoriteButton({super.key, required this.restaurant});

  final Restaurant restaurant;

  Future<void> _toggle(BuildContext context) async {
    final provider = context.read<FavoriteProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final wasFavorite = provider.isFavorite(restaurant.id);

    final success = await provider.toggleFavorite(restaurant);

    final message = !success
        ? 'Gagal memperbarui favorit. Silakan coba lagi.'
        : wasFavorite
            ? '${restaurant.name} dihapus dari favorit.'
            : '${restaurant.name} ditambahkan ke favorit.';
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isFavorite = context.select<FavoriteProvider, bool>(
      (provider) => provider.isFavorite(restaurant.id),
    );

    return IconButton(
      tooltip: isFavorite ? 'Hapus dari favorit' : 'Tambahkan ke favorit',
      onPressed: () => _toggle(context),
      icon: Icon(
        isFavorite ? Icons.favorite : Icons.favorite_border,
        color: isFavorite ? scheme.error : scheme.onSurface,
      ),
    );
  }
}