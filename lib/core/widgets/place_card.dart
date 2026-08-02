import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/models/place_model.dart';
import '../constants/app_colors.dart';
import 'rating_stars.dart';

enum CardLayout { vertical, horizontal }

class PlaceCard extends StatelessWidget {
  final PlaceModel place;
  final VoidCallback onTap;
  final VoidCallback onFavoriteTap;
  final CardLayout layout;

  const PlaceCard({
    super.key,
    required this.place,
    required this.onTap,
    required this.onFavoriteTap,
    this.layout = CardLayout.vertical,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (layout == CardLayout.horizontal) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          width: 260,
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.cardLight,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Header with Hero & Favorite Badge
              Stack(
                children: [
                  Hero(
                    tag: 'place-img-${place.id}',
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(22)),
                      child: CachedNetworkImage(
                        imageUrl: place.heroImage,
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          height: 150,
                          color: isDark ? Colors.grey[800] : Colors.grey[200],
                        ),
                        errorWidget: (context, url, error) => Container(
                          height: 150,
                          color: AppColors.primary.withValues(alpha: 0.1),
                          child: const Icon(Icons.beach_access,
                              color: AppColors.primary, size: 40),
                        ),
                      ),
                    ),
                  ),
                  // Favorite Heart Button
                  Positioned(
                    top: 10,
                    right: 10,
                    child: GestureDetector(
                      onTap: onFavoriteTap,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.black38,
                        child: Icon(
                          place.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: place.isFavorite
                              ? AppColors.favorite
                              : Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  // City Tag
                  Positioned(
                    bottom: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        place.city,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // Content Body
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        RatingStars(rating: place.rating, iconSize: 14),
                        const SizedBox(width: 6),
                        Text(
                          '${place.rating} (${place.reviewCount})',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 14, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            place.distance,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Vertical Card Layout
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(10),
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
          children: [
            Hero(
              tag: 'place-img-${place.id}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CachedNetworkImage(
                  imageUrl: place.heroImage,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => Container(
                    width: 100,
                    height: 100,
                    color: AppColors.primary.withValues(alpha: 0.1),
                    child: const Icon(Icons.place, color: AppColors.primary),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          place.city,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          place.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: place.isFavorite
                              ? AppColors.favorite
                              : Colors.grey,
                          size: 20,
                        ),
                        onPressed: onFavoriteTap,
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                  Text(
                    place.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      RatingStars(rating: place.rating, iconSize: 13),
                      const SizedBox(width: 6),
                      Text(
                        '${place.rating}',
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    place.distance,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
