import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../data/repositories/destination_repository.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(isDarkModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('⚙️ Settings & Info'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // App Branding Header
            Center(
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.explore,
                      size: 44,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Chamal Way',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Guide Touristique du Nord du Maroc',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Settings & Information Options List
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.cardLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.dark_mode_outlined,
                        color: AppColors.primary),
                    title: const Text('Dark Theme'),
                    subtitle: const Text('Activer ou désactiver le mode sombre'),
                    trailing: Switch(
                      value: isDark,
                      activeTrackColor: AppColors.primary,
                      onChanged: (val) {
                        ref.read(isDarkModeProvider.notifier).toggleTheme();
                      },
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.info_outline,
                        color: AppColors.primary),
                    title: const Text('À propos de Chamal Way'),
                    subtitle: const Text('Guide touristique du Nord du Maroc'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/about'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.phone_in_talk_outlined,
                        color: AppColors.secondary),
                    title: const Text('Urgences & Conseils Voyage'),
                    subtitle: const Text('Numéros utiles et informations de sécurité'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/emergency'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // App Version Footer
            const Text(
              'Chamal Way v1.0.1',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
