import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../data/models/place_model.dart';
import '../constants/app_colors.dart';
import 'app_image.dart';

enum CardLayout { vertical, horizontal }

class PlaceCard extends StatelessWidget {
  final PlaceModel place;
  final VoidCallback onTap;
  final VoidCallback onFavoriteTap;
  final CardLayout layout;
  final Widget? actionButton;

  const PlaceCard({
    super.key,
    required this.place,
    required this.onTap,
    required this.onFavoriteTap,
    this.layout = CardLayout.vertical,
    this.actionButton,
  });

  Widget _buildImagePlaceholder(BuildContext context, bool isDark) {
    return Container(
      color: isDark ? Colors.grey[850] : Colors.grey[200],
      child: Center(
        child: Icon(
          Icons.image_outlined,
          color: AppColors.primary.withValues(alpha: 0.4),
          size: 32,
        ),
      ),
    );
  }

  Widget _buildImageError(BuildContext context, bool isDark) {
    return Container(
      color: AppColors.primary.withValues(alpha: 0.08),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.landscape_rounded,
              color: AppColors.primary.withValues(alpha: 0.6),
              size: 36,
            ),
            const SizedBox(height: 4),
            Text(
              place.city,
              style: TextStyle(
                fontSize: 10,
                color: AppColors.primary.withValues(alpha: 0.7),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDebugBadges() {
    if (kReleaseMode) return const SizedBox.shrink();

    final List<Widget> badges = [];

    if (!place.verified) {
      badges.add(
        Container(
          margin: const EdgeInsets.only(right: 4),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.amber.shade800,
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Text(
            'UNVERIFIED',
            style: TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    if (place.images.isEmpty || place.images.first.isEmpty) {
      badges.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.red.shade700,
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Text(
            'NO PHOTO',
            style: TextStyle(
              color: Colors.white,
              fontSize: 9,
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
              // Image Header with Hero, Favorite Badge & Debug Badges
              Stack(
                children: [
                  Hero(
                    tag: 'place-img-${place.id}',
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(22)),
                      child: place.heroImage.isNotEmpty
                          ? AppImage(
                              imagePath: place.heroImage,
                              height: 140,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              placeholder: (context) =>
                                  _buildImagePlaceholder(context, isDark),
                              errorBuilder: (context, error, stack) =>
                                  _buildImageError(context, isDark),
                            )
                          : SizedBox(
                              height: 140,
                              width: double.infinity,
                              child: _buildImageError(context, isDark),
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
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        place.city,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  // Debug Badges (Top Left)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: _buildDebugBadges(),
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
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      place.shortDescription,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            place.category,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (place.priceInfo.isNotEmpty)
                          Text(
                            place.priceInfo,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
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
        margin: const EdgeInsets.only(bottom: 14),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'place-img-${place.id}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: place.heroImage.isNotEmpty
                    ? AppImage(
                        imagePath: place.heroImage,
                        width: 95,
                        height: 95,
                        fit: BoxFit.cover,
                        placeholder: (context) =>
                            _buildImagePlaceholder(context, isDark),
                        errorBuilder: (context, error, stack) =>
                            _buildImageError(context, isDark),
                      )
                    : SizedBox(
                        width: 95,
                        height: 95,
                        child: _buildImageError(context, isDark),
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
                      Expanded(
                        child: Row(
                          children: [
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${place.city} • ${place.category}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            _buildDebugBadges(),
                          ],
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
                  const SizedBox(height: 2),
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
                  Text(
                    place.shortDescription.isNotEmpty
                        ? place.shortDescription
                        : place.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                      height: 1.3,
                    ),
                  ),
                  if (actionButton != null) ...[
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerRight,
                      child: actionButton,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
