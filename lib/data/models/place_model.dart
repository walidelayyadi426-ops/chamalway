class PlaceModel {
  final String id;
  final String name;
  final String city;
  final String category; // Beaches, Mountains, History, Restaurants, Cafes, Hotels, Activities
  final double rating;
  final int reviewCount;
  final String distance; // e.g. "2.4 km"
  final String priceRange; // e.g. "$$", "Budget", "Luxury"
  final String heroImage;
  final List<String> gallery;
  final String description;
  final String history;
  final String openHours;
  final String phone;
  final Map<String, double> coordinates; // {'lat': 35.1713, 'lng': -5.2697}
  final List<String> tags;
  final bool isFeatured;
  final bool isTrending;
  final bool isFavorite;

  const PlaceModel({
    required this.id,
    required this.name,
    required this.city,
    required this.category,
    required this.rating,
    required this.reviewCount,
    required this.distance,
    required this.priceRange,
    required this.heroImage,
    required this.gallery,
    required this.description,
    required this.history,
    required this.openHours,
    required this.phone,
    required this.coordinates,
    required this.tags,
    this.isFeatured = false,
    this.isTrending = false,
    this.isFavorite = false,
  });

  PlaceModel copyWith({
    String? id,
    String? name,
    String? city,
    String? category,
    double? rating,
    int? reviewCount,
    String? distance,
    String? priceRange,
    String? heroImage,
    List<String>? gallery,
    String? description,
    String? history,
    String? openHours,
    String? phone,
    Map<String, double>? coordinates,
    List<String>? tags,
    bool? isFeatured,
    bool? isTrending,
    bool? isFavorite,
  }) {
    return PlaceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      city: city ?? this.city,
      category: category ?? this.category,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      distance: distance ?? this.distance,
      priceRange: priceRange ?? this.priceRange,
      heroImage: heroImage ?? this.heroImage,
      gallery: gallery ?? this.gallery,
      description: description ?? this.description,
      history: history ?? this.history,
      openHours: openHours ?? this.openHours,
      phone: phone ?? this.phone,
      coordinates: coordinates ?? this.coordinates,
      tags: tags ?? this.tags,
      isFeatured: isFeatured ?? this.isFeatured,
      isTrending: isTrending ?? this.isTrending,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
