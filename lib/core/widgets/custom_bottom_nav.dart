import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final items = [
      {'icon': Icons.home_rounded, 'label': 'Home'},
      {'icon': Icons.explore_rounded, 'label': 'Explore'},
      {'icon': Icons.favorite_rounded, 'label': 'Favorites'},
      {'icon': Icons.person_rounded, 'label': 'Profile'},
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      height: 68,
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: isDark ? AppColors.glassBorderDark : AppColors.glassBorderLight,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          final isSelected = currentIndex == index;
          final item = items[index];

          return GestureDetector(
            onTap: () => onTap(index),
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: isSelected
                  ? BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    )
                  : const BoxDecoration(),
              child: Row(
                children: [
                  Icon(
                    item['icon'] as IconData,
                    color: isSelected
                        ? AppColors.primary
                        : (isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight),
                    size: 24,
                  ),
                  if (isSelected) ...[
                    const SizedBox(width: 6),
                    Text(
                      item['label'] as String,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
