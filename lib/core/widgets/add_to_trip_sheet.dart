import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../widgets/app_image.dart';
import '../../data/models/place_model.dart';
import '../../data/providers/trip_provider.dart';

void showAddToTripSheet(BuildContext context, WidgetRef ref, PlaceModel place) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (context) {
      return Consumer(
        builder: (context, ref, child) {
          final tripState = ref.watch(tripProvider);
          final tripNotifier = ref.read(tripProvider.notifier);

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sheet Drag Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[700] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Destination Header Row
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: AppImage(
                        imagePath: place.heroImage,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Add to My Trip',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            place.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            place.city,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                const Text(
                  'Select Day for Itinerary:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                // Days Options Grid / List
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        ...List.generate(tripState.daysCount, (idx) {
                          final dayNum = idx + 1;
                          final placesInDay = tripState.dayPlaces[dayNum] ?? [];
                          final isAlreadyInDay = placesInDay.contains(place.id);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: isAlreadyInDay
                                  ? AppColors.primary.withValues(alpha: 0.08)
                                  : (isDark
                                      ? AppColors.cardDark
                                      : Colors.grey[100]),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isAlreadyInDay
                                    ? AppColors.primary.withValues(alpha: 0.3)
                                    : Colors.transparent,
                              ),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                radius: 16,
                                backgroundColor: isAlreadyInDay
                                    ? AppColors.primary
                                    : AppColors.primary.withValues(alpha: 0.15),
                                child: Text(
                                  '$dayNum',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isAlreadyInDay
                                        ? Colors.white
                                        : AppColors.primary,
                                  ),
                                ),
                              ),
                              title: Text(
                                'Day $dayNum',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                isAlreadyInDay
                                    ? 'Already in Day $dayNum'
                                    : '${placesInDay.length} place${placesInDay.length == 1 ? '' : 's'} planned',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isAlreadyInDay
                                      ? AppColors.primary
                                      : Colors.grey,
                                ),
                              ),
                              trailing: Icon(
                                isAlreadyInDay
                                    ? Icons.check_circle_rounded
                                    : Icons.add_circle_outline_rounded,
                                color: isAlreadyInDay
                                    ? AppColors.primary
                                    : Colors.grey[600],
                              ),
                              onTap: () {
                                Navigator.pop(context);
                                final added = tripNotifier.addPlaceToDay(
                                    place.id, dayNum);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      added
                                          ? '✓ Added "${place.name}" to Day $dayNum'
                                          : 'ℹ️ "${place.name}" is already in Day $dayNum',
                                    ),
                                    duration: const Duration(seconds: 2),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                            ),
                          );
                        }),

                        if (tripState.daysCount < 7) ...[
                          const SizedBox(height: 6),
                          OutlinedButton.icon(
                            onPressed: () {
                              final nextDay = tripState.daysCount + 1;
                              tripNotifier.setDaysCount(nextDay);
                              Navigator.pop(context);
                              final added = tripNotifier.addPlaceToDay(
                                  place.id, nextDay);

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    added
                                        ? '✓ Added "${place.name}" to Day $nextDay'
                                        : 'ℹ️ "${place.name}" is already in Day $nextDay',
                                  ),
                                  duration: const Duration(seconds: 2),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            icon: const Icon(Icons.add, size: 18),
                            label: Text('Add Day ${tripState.daysCount + 1}'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              minimumSize: const Size(double.infinity, 44),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
