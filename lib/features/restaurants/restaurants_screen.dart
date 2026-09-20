import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/place_card.dart';
import '../../core/widgets/empty_state.dart';
import '../../data/repositories/destination_repository.dart';

class RestaurantsScreen extends ConsumerWidget {
  const RestaurantsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(destinationRepositoryProvider);
    final restaurants = repo.getPlacesByCategory('restaurants');

    return Scaffold(
      appBar: AppBar(
        title: const Text('🍽️ Restaurants & Moroccan Dining'),
      ),
      body: restaurants.isEmpty
          ? EmptyState(
              title: 'No Restaurants Available',
              message: 'Check back soon for dining spots.',
              icon: Icons.restaurant_rounded,
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: restaurants.length,
              itemBuilder: (context, index) {
                final place = restaurants[index];
                return PlaceCard(
                  place: place,
                  layout: CardLayout.vertical,
                  onTap: () => context.push('/place/${place.id}'),
                  onFavoriteTap: () {
                    ref.read(favoritesProvider.notifier).toggleFavorite(place.id);
                  },
                );
              },
            ),
    );
  }
}
