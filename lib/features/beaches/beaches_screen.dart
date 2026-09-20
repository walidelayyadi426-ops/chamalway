import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/place_card.dart';
import '../../core/widgets/empty_state.dart';
import '../../data/repositories/destination_repository.dart';

class BeachesScreen extends ConsumerWidget {
  const BeachesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(destinationRepositoryProvider);
    final beaches = repo.getPlacesByCategory('beaches');

    return Scaffold(
      appBar: AppBar(
        title: const Text('🏖️ Beaches of Northern Morocco'),
      ),
      body: beaches.isEmpty
          ? EmptyState(
              title: 'No Beaches Available',
              message: 'Check back soon for curated beaches.',
              icon: Icons.beach_access_rounded,
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: beaches.length,
              itemBuilder: (context, index) {
                final place = beaches[index];
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
