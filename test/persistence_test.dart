import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chamalway/data/models/place_model.dart';
import 'package:chamalway/data/repositories/destination_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SharedPreferences Persistence Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('ThemeModeNotifier toggles and persists dark mode state', () async {
      SharedPreferences.setMockInitialValues({'is_dark_mode': false});
      final themeNotifier = ThemeModeNotifier();

      // Wait for async _loadTheme
      await Future.delayed(const Duration(milliseconds: 50));
      expect(themeNotifier.state, false);

      await themeNotifier.toggleTheme();
      expect(themeNotifier.state, true);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('is_dark_mode'), true);

      // Verify persistence on new notifier instance
      final reloadedThemeNotifier = ThemeModeNotifier();
      await Future.delayed(const Duration(milliseconds: 50));
      expect(reloadedThemeNotifier.state, true);
    });

    test('DestinationRepositoryNotifier persists favorites and ignores invalid IDs', () async {
      SharedPreferences.setMockInitialValues({
        'favorite_place_ids': ['chefchaouen_medina', 'non_existent_place_id_999'],
      });

      final testPlaces = [
        PlaceModel(
          id: 'chefchaouen_medina',
          name: 'Chefchaouen Blue Medina',
          category: 'History',
          city: 'Chefchaouen',
          shortDescription: 'Blue city',
          description: 'Full description',
          images: ['img1.jpg'],
          latitude: 35.17,
          longitude: -5.26,
        ),
        PlaceModel(
          id: 'akchour_waterfalls',
          name: 'Akchour Waterfalls',
          category: 'Mountains',
          city: 'Akchour',
          shortDescription: 'Waterfalls',
          description: 'Full description',
          images: ['img2.jpg'],
          latitude: 35.22,
          longitude: -5.17,
        ),
      ];

      final repoNotifier = DestinationRepositoryNotifier();
      repoNotifier.state = DestinationRepository(testPlaces);

      // Simulate loading saved favorites
      final prefs = await SharedPreferences.getInstance();
      final savedFavs = prefs.getStringList('favorite_place_ids') ?? [];
      repoNotifier.loadSavedFavoritesFromList(savedFavs);

      // chefchaouen_medina is favorite, non_existent_place_id_999 ignored
      final favs = repoNotifier.state.getAllPlaces().where((p) => p.isFavorite).toList();
      expect(favs.length, 1);
      expect(favs.first.id, 'chefchaouen_medina');

      // Toggle favorite on Akchour
      await repoNotifier.toggleFavorite('akchour_waterfalls');
      final updatedPrefs = await SharedPreferences.getInstance();
      final updatedFavs = updatedPrefs.getStringList('favorite_place_ids');

      expect(updatedFavs, contains('chefchaouen_medina'));
      expect(updatedFavs, contains('akchour_waterfalls'));
    });
  });
}
