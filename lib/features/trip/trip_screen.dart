import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/app_image.dart';
import '../../core/widgets/empty_state.dart';
import '../../data/models/place_model.dart';
import '../../data/repositories/destination_repository.dart';
import '../../data/providers/trip_provider.dart';

class TripScreen extends ConsumerStatefulWidget {
  const TripScreen({super.key});

  @override
  ConsumerState<TripScreen> createState() => _TripScreenState();
}

class _TripScreenState extends ConsumerState<TripScreen> {
  void _shareTripItinerary(BuildContext context, TripState tripState, DestinationRepository repo) {
    final buffer = StringBuffer();
    buffer.writeln('🧳 My Northern Morocco Trip (${tripState.daysCount} Days)\n');

    bool hasAnyPlaces = false;

    for (int day = 1; day <= tripState.daysCount; day++) {
      final placeIds = tripState.dayPlaces[day] ?? [];
      buffer.writeln('📍 Day $day');

      if (placeIds.isEmpty) {
        buffer.writeln('  • No activities planned yet');
      } else {
        for (final id in placeIds) {
          final place = repo.getPlaceById(id);
          if (place != null) {
            hasAnyPlaces = true;
            buffer.writeln('  • ${place.name} (${place.city})');
          }
        }
      }
      buffer.writeln();
    }

    buffer.writeln('Planned with ChamalWay Travel Guide 🇲🇦');

    if (!hasAnyPlaces) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add some destinations before sharing your trip!'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    Share.share(buffer.toString(), subject: 'My Northern Morocco Trip Itinerary');
  }

  void _handleDaysCountChange(BuildContext context, WidgetRef ref, int currentCount, int newCount) {
    if (newCount == currentCount) return;

    if (newCount < currentCount) {
      // Show confirmation before reducing duration
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Change Trip Duration?'),
          content: Text(
            'Reducing your trip duration to $newCount days will automatically move all places planned for Day ${newCount + 1} and beyond into Day $newCount.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                ref.read(tripProvider.notifier).setDaysCount(newCount);
              },
              child: const Text('Confirm', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    } else {
      ref.read(tripProvider.notifier).setDaysCount(newCount);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tripState = ref.watch(tripProvider);
    final tripNotifier = ref.read(tripProvider.notifier);
    final repo = ref.watch(destinationRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('🧳 My Trip Itinerary'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Share Itinerary',
            onPressed: () => _shareTripItinerary(context, tripState, repo),
          ),
        ],
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Trip Summary Header & Days Count Selector
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stat Summary Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDark : AppColors.cardLight,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Icon(Icons.calendar_month_rounded,
                                color: AppColors.primary, size: 24),
                            const SizedBox(height: 4),
                            Text(
                              '${tripState.daysCount} Days',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              'Duration',
                              style: TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                          ],
                        ),
                        Container(width: 1, height: 36, color: Colors.grey.withValues(alpha: 0.3)),
                        Column(
                          children: [
                            const Icon(Icons.place_rounded,
                                color: AppColors.secondary, size: 24),
                            const SizedBox(height: 4),
                            Text(
                              '${tripState.totalPlacesCount} Places',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              'Planned',
                              style: TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Trip Duration:',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.cardDark : Colors.grey[200],
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: tripState.daysCount,
                            icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
                            items: List.generate(7, (idx) {
                              final num = idx + 1;
                              return DropdownMenuItem<int>(
                                value: num,
                                child: Text(
                                  '$num ${num == 1 ? 'Day' : 'Days'}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            }),
                            onChanged: (val) {
                              if (val != null) {
                                _handleDaysCountChange(context, ref, tripState.daysCount, val);
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Main Content: Empty State vs Day Itineraries
          if (tripState.totalPlacesCount == 0)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: EmptyState(
                    title: 'Your Trip Itinerary is Empty',
                    message:
                        'Start adding your favorite Northern Morocco destinations to create a personalized day-by-day itinerary!',
                    icon: Icons.luggage_outlined,
                    actionLabel: 'Explore Destinations',
                    onAction: () => context.push('/explore'),
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final dayNum = index + 1;
                    final rawPlaceIds = tripState.dayPlaces[dayNum] ?? [];

                    // Robust lookup: ignore missing/unverified places gracefully
                    final List<PlaceModel> validPlaces = rawPlaceIds
                        .map((id) => repo.getPlaceById(id))
                        .whereType<PlaceModel>()
                        .toList();

                    return Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.cardDark : AppColors.cardLight,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Day Header Bar
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 14,
                                      backgroundColor: AppColors.primary,
                                      child: Text(
                                        '$dayNum',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Day $dayNum',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  '${validPlaces.length} destination${validPlaces.length == 1 ? '' : 's'}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Places List for Day
                          if (validPlaces.isEmpty)
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Center(
                                child: Text(
                                  'No places planned for Day $dayNum yet.',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            )
                          else
                            ReorderableListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(8),
                              itemCount: validPlaces.length,
                              onReorderItem: (oldIdx, newIdx) {
                                tripNotifier.reorderDayPlaces(dayNum, oldIdx, newIdx);
                              },
                              itemBuilder: (context, itemIdx) {
                                final place = validPlaces[itemIdx];
                                return ListTile(
                                  key: ValueKey('day-$dayNum-${place.id}'),
                                  contentPadding:
                                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  leading: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ReorderableDragStartListener(
                                        index: itemIdx,
                                        child: const Icon(
                                          Icons.drag_handle_rounded,
                                          color: Colors.grey,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: AppImage(
                                          imagePath: place.heroImage,
                                          width: 44,
                                          height: 44,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ],
                                  ),
                                  title: Text(
                                    place.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${place.city} • ${place.category}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.close, size: 18, color: Colors.grey),
                                    onPressed: () {
                                      tripNotifier.removePlaceFromDay(place.id, dayNum);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Removed "${place.name}" from Day $dayNum'),
                                          duration: const Duration(seconds: 2),
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    },
                                  ),
                                  onTap: () => context.push('/place/${place.id}'),
                                );
                              },
                            ),
                        ],
                      ),
                    );
                  },
                  childCount: tripState.daysCount,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
