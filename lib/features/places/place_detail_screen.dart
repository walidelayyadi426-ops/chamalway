import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/rating_stars.dart';
import '../../data/repositories/destination_repository.dart';
import '../../data/datasource/morocco_dummy_data.dart';

class PlaceDetailScreen extends ConsumerWidget {
  final String placeId;

  const PlaceDetailScreen({super.key, required this.placeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final repo = ref.watch(destinationRepositoryProvider);
    final place = repo.getPlaceById(placeId);

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
          // Hero Header Image & Silver App Bar
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
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: Colors.black45,
                child: IconButton(
                  icon: const Icon(Icons.share, color: Colors.white),
                  onPressed: () {
                    Share.share(
                      'Check out ${place.name} in ${place.city} on ChamalWay! Download the app to explore Northern Morocco.',
                    );
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
                    child: CachedNetworkImage(
                      imageUrl: place.heroImage,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: AppColors.heroOverlayGradient,
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                              '${place.city} • ${place.distance}',
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

          // Main Details Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick Info Metrics (Rating, Price, Hours)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMetricTile(
                        icon: Icons.star,
                        iconColor: AppColors.starRating,
                        title: '${place.rating}',
                        subtitle: '${place.reviewCount} reviews',
                      ),
                      _buildMetricTile(
                        icon: Icons.attach_money,
                        iconColor: AppColors.success,
                        title: place.priceRange,
                        subtitle: 'Price range',
                      ),
                      _buildMetricTile(
                        icon: Icons.access_time,
                        iconColor: AppColors.secondary,
                        title: 'Hours',
                        subtitle: place.openHours,
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

                  const SizedBox(height: 20),

                  // Historical Insights
                  const Text(
                    'History & Cultural Context',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                      place.history,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Photo Gallery Preview
                  if (place.gallery.isNotEmpty) ...[
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
                        itemCount: place.gallery.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.only(right: 12),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: CachedNetworkImage(
                                imageUrl: place.gallery[index],
                                width: 150,
                                height: 110,
                                fit: BoxFit.cover,
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

                  const SizedBox(height: 24),

                  // Location & Map Preview Card
                  const Text(
                    'Location & Navigation',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 160,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      image: const DecorationImage(
                        image: NetworkImage(
                            'https://images.unsplash.com/photo-1524661135-423995f22d0b?w=800'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            final lat = place.coordinates['lat'];
                            final lng = place.coordinates['lng'];
                            final url = Uri.parse(
                                'https://www.google.com/maps/search/?api=1&query=$lat,$lng');
                            launchUrl(url,
                                mode: LaunchMode.externalApplication);
                          },
                          icon: const Icon(Icons.directions,
                              color: Colors.white),
                          label: const Text(
                            'Get Directions on Google Maps',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Customer Reviews Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Visitor Reviews',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text('Write Review',
                            style: TextStyle(color: AppColors.primary)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...MoroccoDummyData.sampleReviews.map((rev) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color:
                            isDark ? AppColors.cardDark : AppColors.cardLight,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundImage: NetworkImage(rev.userAvatar),
                                radius: 18,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(rev.userName,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    Text(rev.date,
                                        style: const TextStyle(
                                            fontSize: 11, color: Colors.grey)),
                                  ],
                                ),
                              ),
                              RatingStars(rating: rev.rating, iconSize: 14),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(rev.comment,
                              style: const TextStyle(fontSize: 13)),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 28),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 11)),
      ],
    );
  }
}
