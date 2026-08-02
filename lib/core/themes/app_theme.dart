import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.backgroundLight,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      tertiary: AppColors.accent,
      surface: AppColors.cardLight,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.textPrimaryLight,
    ),
    textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme).copyWith(
      displayLarge: GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimaryLight,
      ),
      titleLarge: GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryLight,
      ),
      bodyLarge: GoogleFonts.poppins(
        fontSize: 16,
        color: AppColors.textPrimaryLight,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 14,
        color: AppColors.textSecondaryLight,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.cardLight,
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.backgroundLight,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: AppColors.textPrimaryLight),
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryLight,
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.backgroundDark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      tertiary: AppColors.accent,
      surface: AppColors.cardDark,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.textPrimaryDark,
    ),
    textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme).copyWith(
      displayLarge: GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimaryDark,
      ),
      titleLarge: GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryDark,
      ),
      bodyLarge: GoogleFonts.poppins(
        fontSize: 16,
        color: AppColors.textPrimaryDark,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 14,
        color: AppColors.textSecondaryDark,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.cardDark,
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.backgroundDark,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: AppColors.textPrimaryDark),
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryDark,
      ),
    ),
  );
}
