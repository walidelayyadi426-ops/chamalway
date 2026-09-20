import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/app_image.dart';
import '../../data/repositories/destination_repository.dart';
import '../../data/models/place_model.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  late final MapController _mapController;
  PlaceModel? _selectedPlace;
  String _activeCategory = 'all';
  bool _hasTileError = false;

  // Default initial map center (Northern Morocco: Tangier / Chefchaouen region)
  static const LatLng _initialCenter = LatLng(35.35, -5.35);
  static const double _initialZoom = 9.0;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  bool _isValidCoord(double lat, double lng) {
    if (lat == 0.0 && lng == 0.0) return false;
    if (lat.isNaN || lng.isNaN || lat.isInfinite || lng.isInfinite) return false;
    if (lat < -90.0 || lat > 90.0 || lng < -180.0 || lng > 180.0) return false;
    return true;
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'beaches':
        return Icons.beach_access_rounded;
      case 'mountains':
        return Icons.landscape_rounded;
      case 'history':
        return Icons.account_balance_rounded;
      case 'restaurants':
        return Icons.restaurant_rounded;
      case 'cafes':
        return Icons.local_cafe_rounded;
      case 'hotels':
        return Icons.hotel_rounded;
      case 'shopping':
        return Icons.shopping_bag_rounded;
      default:
        return Icons.place_rounded;
    }
  }

  Widget _buildImagePlaceholder(BuildContext context, bool isDark) {
    return Container(
      color: isDark ? Colors.grey[850] : Colors.grey[200],
      child: const Center(
        child: Icon(
          Icons.image_outlined,
          color: AppColors.primary,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildImageError(BuildContext context, bool isDark) {
    return Container(
      color: AppColors.primary.withValues(alpha: 0.1),
      child: const Center(
        child: Icon(
          Icons.landscape_rounded,
          color: AppColors.primary,
          size: 28,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final repo = ref.watch(destinationRepositoryProvider);
    final places = repo.getPlacesByCategory(_activeCategory);
    final availableCategories = repo.getAvailableCategories();

    final validPlaces = places.where((p) => _isValidCoord(p.latitude, p.longitude)).toList();

    return Scaffold(
      body: Stack(
        children: [
          // FlutterMap GIS Interactive Layer
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _initialCenter,
              initialZoom: _initialZoom,
              minZoom: 7.0,
              maxZoom: 18.0,
              onTap: (_, __) {
                setState(() => _selectedPlace = null);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.chamalway.nordmarocguide',
                tileProvider: NetworkTileProvider(),
                errorTileCallback: (tile, error, stackTrace) {
                  if (!_hasTileError) {
                    setState(() => _hasTileError = true);
                  }
                },
              ),
              MarkerLayer(
                markers: validPlaces.map((place) {
                  final isSelected = _selectedPlace?.id == place.id;
                  return Marker(
                    point: LatLng(place.latitude, place.longitude),
                    width: isSelected ? 50 : 40,
                    height: isSelected ? 50 : 40,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedPlace = place;
                        });
                        _mapController.move(
                          LatLng(place.latitude, place.longitude),
                          _mapController.camera.zoom < 11.0 ? 11.0 : _mapController.camera.zoom,
                        );
                      },
                      child: AnimatedScale(
                        duration: const Duration(milliseconds: 200),
                        scale: isSelected ? 1.25 : 1.0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.secondary : AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2.5),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black38,
                                blurRadius: 6,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Icon(
                            _getCategoryIcon(place.category),
                            color: Colors.white,
                            size: isSelected ? 24 : 20,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              RichAttributionWidget(
                attributions: [
                  TextSourceAttribution(
                    '© OpenStreetMap contributors',
                    onTap: () async {
                      final url = Uri.parse('https://www.openstreetmap.org/copyright');
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),

          // Top Floating Filter Bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildMapFilterChip('all', '🗺️ All Pins'),
                    ...availableCategories.map((cat) {
                      return _buildMapFilterChip(cat.id, cat.title);
                    }),
                  ],
                ),
              ),
            ),
          ),

          // Non-blocking Banner if Map Tiles Fail to Load (No Internet)
          if (_hasTileError)
            SafeArea(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 60, 16, 0),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? Colors.amber.withValues(alpha: 0.4) : Colors.amber[700]!,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.wifi_off_rounded,
                      color: isDark ? Colors.amber[300] : Colors.amber[900],
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Map background needs an internet connection',
                        style: TextStyle(
                          color: isDark ? Colors.amber[100] : Colors.amber[900],
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _hasTileError = false),
                      child: Icon(
                        Icons.close,
                        size: 18,
                        color: isDark ? Colors.amber[300] : Colors.amber[900],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Floating Re-Center Button
          Positioned(
            right: 16,
            bottom: _selectedPlace != null ? 220 : 100,
            child: FloatingActionButton.small(
              heroTag: 'recenter-map-fab',
              backgroundColor: AppColors.primary,
              onPressed: () {
                _mapController.move(_initialCenter, _initialZoom);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Centered map on Northern Morocco 🇲🇦'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const Icon(Icons.center_focus_strong, color: Colors.white),
            ),
          ),

          // Selected Place Bottom Popup Card
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
                      child: _selectedPlace!.heroImage.isNotEmpty
                          ? AppImage(
                              imagePath: _selectedPlace!.heroImage,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              placeholder: (context) =>
                                  _buildImagePlaceholder(context, isDark),
                              errorBuilder: (context, error, stack) =>
                                  _buildImageError(context, isDark),
                            )
                          : SizedBox(
                              width: 80,
                              height: 80,
                              child: _buildImageError(context, isDark),
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
                            '${_selectedPlace!.city} • ${_selectedPlace!.category}',
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
