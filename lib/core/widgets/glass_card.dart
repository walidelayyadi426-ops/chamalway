import 'dart:ui';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final Border? border;

  const GlassCard({
    super.key,
    required this.child,
    this.blur = 12.0,
    this.opacity = 0.15,
    this.borderRadius,
    this.padding,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultRadius = borderRadius ?? BorderRadius.circular(20);

    return ClipRRect(
      borderRadius: defaultRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.black.withValues(alpha: opacity + 0.2)
                : Colors.white.withValues(alpha: opacity + 0.5),
            borderRadius: defaultRadius,
            border: border ??
                Border.all(
                  color: isDark
                      ? AppColors.glassBorderDark
                      : AppColors.glassBorderLight,
                  width: 1.5,
                ),
          ),
          child: child,
        ),
      ),
    );
  }
}
