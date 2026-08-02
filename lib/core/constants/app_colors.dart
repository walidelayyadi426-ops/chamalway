import 'package:flutter/material.dart';

class AppColors {
  // Brand Palette
  static const Color primary = Color(0xFF0F766E); // Ocean Green
  static const Color secondary = Color(0xFFF4A261); // Sunset Orange
  static const Color accent = Color(0xFF2A9D8F); // Turquoise

  // Neutral Backgrounds
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color backgroundDark = Color(0xFF111827);

  // Surface & Cards
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF1F2937);

  // Typography
  static const Color textPrimaryLight = Color(0xFF1F2937);
  static const Color textSecondaryLight = Color(0xFF6B7280);
  static const Color textPrimaryDark = Color(0xFFF9FAFB);
  static const Color textSecondaryDark = Color(0xFF9CA3AF);

  // Status & Actions
  static const Color success = Color(0xFF10B981);
  static const Color favorite = Color(0xFFEF4444);
  static const Color starRating = Color(0xFFFFB800);

  // Glassmorphic Strokes
  static const Color glassBorderLight = Color(0x33FFFFFF);
  static const Color glassBorderDark = Color(0x1AFFFFFF);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0F766E), Color(0xFF2A9D8F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient sunsetGradient = LinearGradient(
    colors: [Color(0xFFF4A261), Color(0xFFE76F51)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroOverlayGradient = LinearGradient(
    colors: [Colors.transparent, Colors.black87],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
