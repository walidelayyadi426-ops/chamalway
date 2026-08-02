import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ℹ️ About & Travel Guide'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // App Logo Banner
          Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.12),
                  ),
                  child: const Icon(Icons.explore,
                      size: 60, color: AppColors.primary),
                ),
                const SizedBox(height: 12),
                const Text(
                  AppConstants.appName,
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  AppConstants.appTagline,
                  style: TextStyle(color: AppColors.secondary, fontSize: 14),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Version 1.0.0 • Premium Edition',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Sunrise & Sunset Tool Widget
          const Text(
            '🌅 Sun & Ocean Tide Times (Tangier)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppColors.sunsetGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                Column(
                  children: [
                    Icon(Icons.wb_twilight, color: Colors.white, size: 28),
                    SizedBox(height: 4),
                    Text('Sunrise', style: TextStyle(color: Colors.white70)),
                    Text('06:38 AM',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                  ],
                ),
                VerticalDivider(color: Colors.white38),
                Column(
                  children: [
                    Icon(Icons.nights_stay, color: Colors.white, size: 28),
                    SizedBox(height: 4),
                    Text('Sunset', style: TextStyle(color: Colors.white70)),
                    Text('08:42 PM',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Emergency Numbers List
          const Text(
            '🚨 Emergency Numbers in Morocco',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : AppColors.cardLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: AppConstants.emergencyNumbers.entries.map((entry) {
                return ListTile(
                  leading: const Icon(Icons.phone_in_talk,
                      color: AppColors.favorite),
                  title: Text(entry.key),
                  trailing: Text(
                    entry.value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  onTap: () {
                    final phoneUri = Uri.parse('tel:${entry.value}');
                    launchUrl(phoneUri);
                  },
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 28),

          // Local Travel Tips
          const Text(
            '💡 Local Travel Tips',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : AppColors.cardLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  '• Currency: Moroccan Dirham (MAD). 1 USD ≈ 10 MAD.',
                  style: TextStyle(height: 1.5),
                ),
                SizedBox(height: 8),
                Text(
                  '• Best time for Chefchaouen: Early morning (7:00 - 9:00 AM) for photography without crowds.',
                  style: TextStyle(height: 1.5),
                ),
                SizedBox(height: 8),
                Text(
                  '• Taxis: Small blue taxis operate in Tangier & Tetouan using taximeter.',
                  style: TextStyle(height: 1.5),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
