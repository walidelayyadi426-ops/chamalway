import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/place_card.dart';
import '../../core/widgets/empty_state.dart';
import '../../data/repositories/destination_repository.dart';

class HistoricalScreen extends ConsumerWidget {
  const HistoricalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(destinationRepositoryProvider);
    final historyPlaces = repo.getPlacesByCategory('history');

    return Scaffold(
      appBar: AppBar(
        title: const Text('🏰 Historical & Cultural Landmarks'),
      ),
      body: historyPlaces.isEmpty
          ? EmptyState(
              title: 'No Historical Sites Available',
              message: 'Check back soon for historic landmarks.',
              icon: Icons.account_balance_rounded,
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: historyPlaces.length,
              itemBuilder: (context, index) {
                final place = historyPlaces[index];
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
