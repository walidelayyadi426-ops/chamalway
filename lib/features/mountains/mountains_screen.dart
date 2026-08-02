import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/place_card.dart';
import '../../data/repositories/destination_repository.dart';

class MountainsScreen extends ConsumerWidget {
  const MountainsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(destinationRepositoryProvider);
    final mountains = repo.getPlacesByCategory('mountains');

    return Scaffold(
      appBar: AppBar(
        title: const Text('🏔️ Rif Mountains & Hikes'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: mountains.length,
        itemBuilder: (context, index) {
          final place = mountains[index];
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
