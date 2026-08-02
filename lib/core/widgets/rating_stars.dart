import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class RatingStars extends StatelessWidget {
  final double rating;
  final double iconSize;

  const RatingStars({
    super.key,
    required this.rating,
    this.iconSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          return Icon(Icons.star, color: AppColors.starRating, size: iconSize);
        } else if (index < rating && (rating - index) >= 0.5) {
          return Icon(Icons.star_half, color: AppColors.starRating, size: iconSize);
        } else {
          return Icon(Icons.star_border, color: AppColors.starRating, size: iconSize);
        }
      }),
    );
  }
}
