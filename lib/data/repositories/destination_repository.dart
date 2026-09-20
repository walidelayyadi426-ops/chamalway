import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../models/place_model.dart';
import '../models/category_model.dart';

String _removeAccents(String text) {
  const withAccents = 'àáâãäåòóôõöøèéêëçìíîïùúûüñÿÀÁÂÃÄÅÒÓÔÕÖØÈÉÊËÇÌÍÎÏÙÚÛÜÑÝ’\'';
  const withoutAccents = 'aaaaaaoooooeeeeciiiiuuuunyAAAAAAOOOOOOEEEECIIIIUUUUNY  ';
  var result = text;
  for (int i = 0; i < withAccents.length; i++) {
    result = result.replaceAll(withAccents[i], withoutAccents[i]);
  }
  return result;
}

class DestinationRepository {
  List<PlaceModel> _allRawPlaces = [];

  DestinationRepository([List<PlaceModel>? initialPlaces]) {
    if (initialPlaces != null && initialPlaces.isNotEmpty) {
      _allRawPlaces = List.from(initialPlaces);
    }
  }

  void setPlaces(List<PlaceModel> places) {
    _allRawPlaces = List.from(places);
  }

  /// Returns places filtered by build mode:
  /// - In release builds (kReleaseMode), only returns verified places with at least 1 image.
  /// - In debug/profile builds, returns all places.
  List<PlaceModel> get _places {
    if (kReleaseMode) {
      return _allRawPlaces.where((p) {
        return p.verified && p.images.isNotEmpty && p.images.first.isNotEmpty;
      }).toList();
    }
    return _allRawPlaces;
  }

  List<PlaceModel> getAllPlaces() => _places;

  List<PlaceModel> getFeaturedPlaces() =>
      _places.where((p) => p.isFeatured).toList();

  List<PlaceModel> getTrendingPlaces() =>
      _places.where((p) => p.isTrending).toList();

  List<PlaceModel> getPlacesByCategory(String categoryId) {
    if (categoryId.toLowerCase() == 'all') return _places;
    return _places
        .where((p) => p.category.toLowerCase() == categoryId.toLowerCase())
        .toList();
  }

  PlaceModel? getPlaceById(String id) {
    try {
      return _places.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Accent-insensitive & case-insensitive search across name, city, category, tags, and description
  List<PlaceModel> searchPlaces(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return _places;

    final q = _removeAccents(trimmed.toLowerCase());

    return _places.where((p) {
      final nameNorm = _removeAccents(p.name.toLowerCase());
      final cityNorm = _removeAccents(p.city.toLowerCase());
      final catNorm = _removeAccents(p.category.toLowerCase());
      final descNorm = _removeAccents(p.shortDescription.toLowerCase());

      if (nameNorm.contains(q) ||
          cityNorm.contains(q) ||
          catNorm.contains(q) ||
          descNorm.contains(q)) {
        return true;
      }

      return p.tags.any((t) => _removeAccents(t.toLowerCase()).contains(q));
    }).toList();
  }

  /// Returns distinct list of cities from visible places
  List<String> getAvailableCities() {
    final cities = _places.map((p) => p.city).toSet().toList();
    cities.sort();
    return cities;
  }

  /// Returns only categories that have at least kMinPlacesPerCategory visible places
  List<CategoryModel> getAvailableCategories() {
    final Map<String, int> counts = {};
    for (final p in _places) {
      final key = p.category.toLowerCase();
      counts[key] = (counts[key] ?? 0) + 1;
    }

    return CategoryModel.allCategories.where((cat) {
      final count = counts[cat.id.toLowerCase()] ?? 0;
      return count >= AppConstants.kMinPlacesPerCategory;
    }).toList();
  }

  void toggleFavorite(String id) {
    _allRawPlaces = _allRawPlaces.map((p) {
      if (p.id == id) {
        return p.copyWith(isFavorite: !p.isFavorite);
      }
      return p;
    }).toList();
  }

  /// Helper to load places directly from assets/data/places.json
  static Future<List<PlaceModel>> loadPlacesFromJsonAsset() async {
    try {
      final jsonString =
          await rootBundle.loadString(AppConstants.placesJsonPath);
      final List<dynamic> list = jsonDecode(jsonString);
      return list.map((json) => PlaceModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }
}

// Global Repository State Notifier for Riverpod
class DestinationRepositoryNotifier
    extends StateNotifier<DestinationRepository> {
  DestinationRepositoryNotifier() : super(DestinationRepository());

  static const String _favoritesKey = 'favorite_place_ids';

  Future<void> loadPlaces() async {
    final places = await DestinationRepository.loadPlacesFromJsonAsset();
    var repo = DestinationRepository(places);

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedFavIds = prefs.getStringList(_favoritesKey) ?? [];
      if (savedFavIds.isNotEmpty) {
        repo = _applyFavoriteIds(repo, savedFavIds);
      }
    } catch (_) {}

    state = repo;
  }

  DestinationRepository _applyFavoriteIds(
      DestinationRepository repo, List<String> savedFavIds) {
    final validPlaceIds = repo.getAllPlaces().map((p) => p.id).toSet();
    final updated = repo.getAllPlaces().map((p) {
      if (savedFavIds.contains(p.id) && validPlaceIds.contains(p.id)) {
        return p.copyWith(isFavorite: true);
      }
      return p;
    }).toList();
    return DestinationRepository(updated);
  }

  void loadSavedFavoritesFromList(List<String> savedFavIds) {
    state = _applyFavoriteIds(state, savedFavIds);
  }

  Future<void> toggleFavorite(String id) async {
    state.toggleFavorite(id);
    state = DestinationRepository(state.getAllPlaces());

    try {
      final prefs = await SharedPreferences.getInstance();
      final favIds = state
          .getAllPlaces()
          .where((p) => p.isFavorite)
          .map((p) => p.id)
          .toList();
      await prefs.setStringList(_favoritesKey, favIds);
    } catch (_) {}
  }
}

final destinationRepositoryProvider = StateNotifierProvider<
    DestinationRepositoryNotifier, DestinationRepository>((ref) {
  final notifier = DestinationRepositoryNotifier();
  notifier.loadPlaces();
  return notifier;
});

class FavoritesNotifier extends StateNotifier<List<PlaceModel>> {
  FavoritesNotifier(this._ref) : super([]) {
    _updateFavorites();
  }

  final Ref _ref;

  void _updateFavorites() {
    final repo = _ref.read(destinationRepositoryProvider);
    state = repo.getAllPlaces().where((p) => p.isFavorite).toList();
  }

  void toggleFavorite(String id) {
    _ref.read(destinationRepositoryProvider.notifier).toggleFavorite(id);
    _updateFavorites();
  }

  void refresh() {
    _updateFavorites();
  }
}

final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, List<PlaceModel>>((ref) {
  ref.watch(destinationRepositoryProvider);
  return FavoritesNotifier(ref);
});

// Theme Mode Provider with SharedPreferences persistence
class ThemeModeNotifier extends StateNotifier<bool> {
  ThemeModeNotifier() : super(false) {
    _loadTheme();
  }

  static const String _themeKey = 'is_dark_mode';

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      state = prefs.getBool(_themeKey) ?? false;
    } catch (_) {}
  }

  Future<void> toggleTheme() async {
    state = !state;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themeKey, state);
    } catch (_) {}
  }
}

final isDarkModeProvider =
    StateNotifierProvider<ThemeModeNotifier, bool>((ref) {
  return ThemeModeNotifier();
});

// Selected Category Provider
final selectedCategoryProvider = StateProvider<String>((ref) => 'all');
