import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_colors.dart';
import '../../data/repositories/destination_repository.dart';
import '../../data/models/place_model.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  PlaceModel? _selectedPlace;
  String _activeCategory = 'all';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final repo = ref.watch(destinationRepositoryProvider);
    final places = repo.getPlacesByCategory(_activeCategory);

    return Scaffold(
      body: Stack(
        children: [
          // Styled Map Visualizer Container
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
            ),
            child: Stack(
              children: [
                // Map Background Imagery Layer
                Positioned.fill(
                  child: Opacity(
                    opacity: isDark ? 0.35 : 0.65,
                    child: Image.network(
                      'https://images.unsplash.com/photo-1524661135-423995f22d0b?w=1200',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                // Interactive Custom Pins Placement
                ...places.asMap().entries.map((entry) {
                  final index = entry.key;
                  final place = entry.value;
                  // Dynamic spread coordinates on canvas mockup
                  final top = 140.0 + (index * 70) % 400;
                  final left = 40.0 + (index * 110) % 300;

                  final isSelected = _selectedPlace?.id == place.id;

                  return Positioned(
                    top: top,
                    left: left,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedPlace = place;
                        });
                      },
                      child: AnimatedScale(
                        duration: const Duration(milliseconds: 250),
                        scale: isSelected ? 1.3 : 1.0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.secondary
                                : AppColors.primary,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black38,
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isSelected
                                    ? Icons.location_on
                                    : Icons.place,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                place.name.split(' ').first,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),

          // Top Floating Filter Bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildMapFilterChip('all', '🗺️ All Pins'),
                    _buildMapFilterChip('beaches', '🏖️ Beaches'),
                    _buildMapFilterChip('mountains', '🏔️ Mountains'),
                    _buildMapFilterChip('history', '🏰 History'),
                    _buildMapFilterChip('restaurants', '🍽️ Food'),
                  ],
                ),
              ),
            ),
          ),

          // Floating Current Location Trigger
          Positioned(
            right: 16,
            bottom: _selectedPlace != null ? 220 : 100,
            child: FloatingActionButton.small(
              heroTag: 'my-location-fab',
              backgroundColor: AppColors.primary,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Centered on current GPS location: Tangier'),
                  ),
                );
              },
              child: const Icon(Icons.my_location, color: Colors.white),
            ),
          ),

          // Selected Place Popup Card at Bottom
          if (_selectedPlace != null)
            Positioned(
              left: 20,
              right: 20,
              bottom: 100,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : AppColors.cardLight,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: CachedNetworkImage(
                        imageUrl: _selectedPlace!.heroImage,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedPlace!.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_selectedPlace!.city} • ⭐ ${_selectedPlace!.rating}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () {
                              context.push('/place/${_selectedPlace!.id}');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'View Details',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () {
                        setState(() => _selectedPlace = null);
                      },
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMapFilterChip(String id, String label) {
    final isSelected = _activeCategory == id;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        selected: isSelected,
        label: Text(label),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        selectedColor: AppColors.primary,
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        onSelected: (_) {
          setState(() {
            _activeCategory = id;
            _selectedPlace = null;
          });
        },
      ),
    );
  }
}
