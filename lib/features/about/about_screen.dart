import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
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
                FutureBuilder<PackageInfo>(
                  future: PackageInfo.fromPlatform(),
                  builder: (context, snapshot) {
                    final versionText = snapshot.hasData
                        ? 'Version ${snapshot.data!.version} (Build ${snapshot.data!.buildNumber}) • Travel Guide'
                        : 'Chamal Way Travel Guide';
                    return Text(
                      versionText,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // About Project Description
          const Text(
            '📌 About the Project',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : AppColors.cardLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Chamal Way is your interactive travel companion to explore the best destinations in Northern Morocco. '
              'Discover the blue-washed streets of Chefchaouen, stunning beaches of Tangier, Martil, and Al Hoceima, the enchanted waterfalls of Akchour, and the rich historical heritage of the region.',
              style: TextStyle(fontSize: 14, height: 1.5),
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
