import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../data/repositories/destination_repository.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(isDarkModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('⚙️ App Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Appearance',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 8),
          Card(
            child: SwitchListTile(
              secondary: const Icon(Icons.dark_mode, color: AppColors.primary),
              title: const Text('Dark Mode'),
              subtitle: const Text('Switch between Light and Dark interface'),
              value: isDark,
              activeTrackColor: AppColors.primary,
              onChanged: (val) {
                ref.read(isDarkModeProvider.notifier).toggleTheme();
              },
            ),
          ),
        ],
      ),
    );
  }
}
