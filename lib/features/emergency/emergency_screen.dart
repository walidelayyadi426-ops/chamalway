import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';

class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('🚨 Emergency & Travel Tips'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Header Banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.favorite.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.phone_in_talk, size: 40, color: AppColors.favorite),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Emergency Numbers',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Tap a number to place a call directly.',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

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
                  subtitle: const Text('Tap to call'),
                  trailing: Text(
                    entry.value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  onTap: () async {
                    final phoneUri = Uri.parse('tel:${entry.value}');
                    bool launched = false;
                    try {
                      if (await canLaunchUrl(phoneUri)) {
                        launched = await launchUrl(phoneUri);
                      }
                    } catch (_) {}

                    if (!launched && context.mounted) {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          title: Text(entry.key),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('Phone calls are not supported on this device.'),
                              const SizedBox(height: 16),
                              SelectableText(
                                entry.value,
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Close'),
                            ),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: () {
                                Clipboard.setData(
                                    ClipboardData(text: entry.value));
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Copied ${entry.value} to clipboard!'),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.copy, size: 18, color: Colors.white),
                              label: const Text('Copy',
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      );
                    }
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
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
