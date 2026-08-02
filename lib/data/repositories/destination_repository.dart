import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/place_model.dart';
import '../datasource/morocco_dummy_data.dart';

class DestinationRepository {
  List<PlaceModel> _places = List.from(MoroccoDummyData.places);

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

  List<PlaceModel> searchPlaces(String query) {
    if (query.trim().isEmpty) return _places;
    final q = query.toLowerCase();
    return _places.where((p) {
      return p.name.toLowerCase().contains(q) ||
          p.city.toLowerCase().contains(q) ||
          p.category.toLowerCase().contains(q) ||
          p.tags.any((t) => t.toLowerCase().contains(q));
    }).toList();
  }

  void toggleFavorite(String id) {
    _places = _places.map((p) {
      if (p.id == id) {
        return p.copyWith(isFavorite: !p.isFavorite);
      }
      return p;
    }).toList();
  }
}

// Providers
final destinationRepositoryProvider = Provider<DestinationRepository>((ref) {
  return DestinationRepository();
});

class FavoritesNotifier extends StateNotifier<List<PlaceModel>> {
  FavoritesNotifier(this._repository)
      : super(_repository.getAllPlaces().where((p) => p.isFavorite).toList());

  final DestinationRepository _repository;

  void toggleFavorite(String id) {
    _repository.toggleFavorite(id);
    state = _repository.getAllPlaces().where((p) => p.isFavorite).toList();
  }
}

final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, List<PlaceModel>>((ref) {
  final repo = ref.watch(destinationRepositoryProvider);
  return FavoritesNotifier(repo);
});

// Theme Mode Provider
class ThemeModeNotifier extends StateNotifier<bool> {
  ThemeModeNotifier() : super(false); // false = Light, true = Dark

  void toggleTheme() {
    state = !state;
  }
}

final isDarkModeProvider =
    StateNotifierProvider<ThemeModeNotifier, bool>((ref) {
  return ThemeModeNotifier();
});

// Selected Category Provider
final selectedCategoryProvider = StateProvider<String>((ref) => 'all');
