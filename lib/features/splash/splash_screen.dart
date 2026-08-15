import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkInitialRoute();
  }

  Future<void> _checkInitialRoute() async {
    try {
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) return;
      final prefs = await SharedPreferences.getInstance();
      final seenOnboarding = prefs.getBool('seen_onboarding') ?? false;
      if (mounted) {
        if (seenOnboarding) {
          context.go('/home');
        } else {
          context.go('/onboarding');
        }
      }
    } catch (_) {
      if (mounted) {
        context.go('/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0F766E),
              Color(0xFF111827),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo Container with Glass Effect & Hero Animation
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.12),
                border: Border.all(color: Colors.white24, width: 2),
              ),
              child: const Icon(
                Icons.explore,
                size: 72,
                color: AppColors.secondary,
              ),
            )
                .animate()
                .scale(duration: 800.ms, curve: Curves.easeOutBack)
                .fade(duration: 600.ms),
            const SizedBox(height: 24),

            // App Name
            const Text(
              AppConstants.appName,
              style: TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
            ).animate().slideY(begin: 0.3, duration: 600.ms).fade(),

            const SizedBox(height: 8),

            // Tagline
            const Text(
              AppConstants.appTagline,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.secondary,
                fontWeight: FontWeight.w500,
              ),
            ).animate().fade(delay: 400.ms, duration: 600.ms),

            const SizedBox(height: 60),

            // Loading Indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
              strokeWidth: 3,
            ).animate().fade(delay: 800.ms),
          ],
        ),
      ),
    );
  }
}
