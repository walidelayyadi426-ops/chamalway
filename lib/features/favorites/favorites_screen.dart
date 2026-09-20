import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/place_card.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/add_to_trip_sheet.dart';
import '../../data/repositories/destination_repository.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Favorites'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.offline_pin, size: 14, color: AppColors.success),
                SizedBox(width: 4),
                Text(
                  'Offline Ready',
                  style: TextStyle(
                    color: AppColors.success,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: favorites.isEmpty
          ? EmptyState(
              title: 'No Saved Places Yet',
              message:
                  'Tap the heart icon on any beach, mountain, cafe or historical spot to save it here for instant offline access.',
              icon: Icons.favorite_border_rounded,
              actionLabel: 'Explore Destinations',
              onAction: () => context.go('/explore'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final place = favorites[index];
                return PlaceCard(
                  place: place,
                  layout: CardLayout.vertical,
                  onTap: () => context.push('/place/${place.id}'),
                  onFavoriteTap: () {
                    ref
                        .read(favoritesProvider.notifier)
                        .toggleFavorite(place.id);
                  },
                  actionButton: InkWell(
                    onTap: () => showAddToTripSheet(context, ref, place),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add_circle_outline,
                              size: 14, color: AppColors.primary),
                          SizedBox(width: 4),
                          Text(
                            'My Trip',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
