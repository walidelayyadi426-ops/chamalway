import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/app_image.dart';
import '../../core/widgets/add_to_trip_sheet.dart';
import '../../data/repositories/destination_repository.dart';
import '../../data/models/place_model.dart';

class PlaceDetailScreen extends ConsumerStatefulWidget {
  final String placeId;

  const PlaceDetailScreen({super.key, required this.placeId});

  @override
  ConsumerState<PlaceDetailScreen> createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends ConsumerState<PlaceDetailScreen> {
  int _activeImageIndex = 0;

  Widget _buildImagePlaceholder(BuildContext context, bool isDark) {
    return Container(
      color: isDark ? Colors.grey[850] : Colors.grey[200],
      child: Center(
        child: Icon(
          Icons.image_outlined,
          color: AppColors.primary.withValues(alpha: 0.4),
          size: 48,
        ),
      ),
    );
  }

  Widget _buildImageError(BuildContext context, bool isDark, String cityName) {
    return Container(
      color: AppColors.primary.withValues(alpha: 0.1),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.landscape_rounded,
              color: AppColors.primary.withValues(alpha: 0.6),
              size: 56,
            ),
            const SizedBox(height: 8),
            Text(
              cityName,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.primary.withValues(alpha: 0.8),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDebugBadges(PlaceModel place) {
    if (kReleaseMode) return const SizedBox.shrink();

    final List<Widget> badges = [];

    if (!place.verified) {
      badges.add(
        Container(
          margin: const EdgeInsets.only(right: 6),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.amber.shade800,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'UNVERIFIED',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    if (place.images.isEmpty || place.images.first.isEmpty) {
      badges.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.red.shade700,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'NO PHOTO',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    if (badges.isEmpty) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: badges,
    );
  }

  Future<void> _openDirections(BuildContext context, PlaceModel place) async {
    final appleMapsUrl = Uri.parse(
        'https://maps.apple.com/?daddr=${place.latitude},${place.longitude}&q=${Uri.encodeComponent(place.name)}');
    final googleMapsUrl = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${place.latitude},${place.longitude}');

    try {
      if (await canLaunchUrl(appleMapsUrl)) {
        await launchUrl(appleMapsUrl, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open map navigation application.'),
            ),
          );
        }
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error launching navigation.'),
          ),
        );
      }
    }
  }

  void _sharePlace(PlaceModel place) {
    final text =
        '📍 ${place.name} (${place.city}, Morocco)\n${place.shortDescription}\n\nDiscovered via ChamalWay Travel Guide!';
    Share.share(text, subject: place.name);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final repo = ref.watch(destinationRepositoryProvider);
    final place = repo.getPlaceById(widget.placeId);

    if (place == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Place Not Found')),
        body: const Center(child: Text('Destination details are unavailable.')),
      );
    }

    final isFav = ref.watch(favoritesProvider).any((p) => p.id == place.id);

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Hero Header Image Gallery & Silver App Bar
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            leading: CircleAvatar(
              backgroundColor: Colors.black45,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            actions: [
              CircleAvatar(
                backgroundColor: Colors.black45,
                child: IconButton(
                  icon: Icon(
                    isFav ? Icons.favorite : Icons.favorite_border,
                    color: isFav ? AppColors.favorite : Colors.white,
                  ),
                  onPressed: () {
                    ref
                        .read(favoritesProvider.notifier)
                        .toggleFavorite(place.id);
                  },
                ),
              ),
              const SizedBox(width: 16),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'place-img-${place.id}',
                    child: place.images.isNotEmpty
                        ? PageView.builder(
                            itemCount: place.images.length,
                            onPageChanged: (idx) {
                              setState(() => _activeImageIndex = idx);
                            },
                            itemBuilder: (context, index) {
                              return AppImage(
                                imagePath: place.images[index],
                                fit: BoxFit.cover,
                                placeholder: (context) =>
                                    _buildImagePlaceholder(context, isDark),
                                errorBuilder: (context, error, stack) =>
                                    _buildImageError(
                                        context, isDark, place.city),
                              );
                            },
                          )
                        : _buildImageError(context, isDark, place.city),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: AppColors.heroOverlayGradient,
                    ),
                  ),
                  // Dots indicator for multiple images
                  if (place.images.length > 1)
                    Positioned(
                      top: 60,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          place.images.length,
                          (i) => Container(
                            width: _activeImageIndex == i ? 18 : 6,
                            height: 6,
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            decoration: BoxDecoration(
                              color: _activeImageIndex == i
                                  ? Colors.white
                                  : Colors.white54,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                place.category.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _buildDebugBadges(place),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          place.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                color: AppColors.secondary, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              place.city,
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 13),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Action Buttons Bar (Favorite, Directions, Share, Add to Trip)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : AppColors.cardLight,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildActionButton(
                      icon: isFav ? Icons.favorite : Icons.favorite_border,
                      color: isFav ? AppColors.favorite : AppColors.primary,
                      label: isFav ? 'Saved' : 'Favorite',
                      onTap: () {
                        ref
                            .read(favoritesProvider.notifier)
                            .toggleFavorite(place.id);
                      },
                      isDark: isDark,
                    ),
                    _buildActionButton(
                      icon: Icons.directions_outlined,
                      color: AppColors.primary,
                      label: 'Directions',
                      onTap: () => _openDirections(context, place),
                      isDark: isDark,
                    ),
                    _buildActionButton(
                      icon: Icons.share_outlined,
                      color: AppColors.secondary,
                      label: 'Share',
                      onTap: () => _sharePlace(place),
                      isDark: isDark,
                    ),
                    _buildActionButton(
                      icon: Icons.add_circle_outline,
                      color: AppColors.accent,
                      label: 'My Trip',
                      onTap: () => showAddToTripSheet(context, ref, place),
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Main Details Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick Info Metrics (Duration, Price, Best Time)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMetricTile(
                        icon: Icons.timer_outlined,
                        iconColor: AppColors.secondary,
                        title: place.estimatedDuration.isNotEmpty
                            ? place.estimatedDuration
                            : 'Flexible',
                        subtitle: 'Duration',
                        isDark: isDark,
                      ),
                      _buildMetricTile(
                        icon: Icons.sell_outlined,
                        iconColor: AppColors.success,
                        title: place.priceInfo.isNotEmpty
                            ? place.priceInfo
                            : 'Free',
                        subtitle: 'Price Info',
                        isDark: isDark,
                      ),
                      _buildMetricTile(
                        icon: Icons.wb_sunny_outlined,
                        iconColor: Colors.amber,
                        title: place.bestTimeToVisit.isNotEmpty
                            ? place.bestTimeToVisit
                            : 'Year-round',
                        subtitle: 'Best Time',
                        isDark: isDark,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Description
                  const Text(
                    'About Destination',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    place.description,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),

                  if (place.whyVisit.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    const Text(
                      'Why Visit',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.2)),
                      ),
                      child: Text(
                        place.whyVisit,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Photo Gallery Preview
                  if (place.images.length > 1) ...[
                    const Text(
                      'Photo Gallery',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 110,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: place.images.length,
                        itemBuilder: (context, index) {
                          final imgUrl = place.images[index];
                          return GestureDetector(
                            onTap: () {
                              setState(() => _activeImageIndex = index);
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: _activeImageIndex == index
                                    ? Border.all(
                                        color: AppColors.primary, width: 2)
                                    : null,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: AppImage(
                                  imagePath: imgUrl,
                                  width: 150,
                                  height: 110,
                                  fit: BoxFit.cover,
                                  placeholder: (context) =>
                                      _buildImagePlaceholder(context, isDark),
                                  errorBuilder: (context, error, stack) =>
                                      _buildImageError(
                                          context, isDark, place.city),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Tags
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: place.tags.map((tag) {
                      return Chip(
                        label: Text('#$tag'),
                        backgroundColor: isDark
                            ? AppColors.cardDark
                            : AppColors.cardLight,
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool isDark,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 26),
          const SizedBox(height: 6),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
