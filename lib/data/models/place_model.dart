class PlaceModel {
  final String id;
  final String name;
  final String city;
  final String category; // Beaches, Mountains, History, Restaurants, Cafes, Hotels, Shopping
  final String shortDescription;
  final String description;
  final String whyVisit;
  final String bestTimeToVisit;
  final String estimatedDuration;
  final String priceInfo;
  final double latitude;
  final double longitude;
  final List<String> images;
  final List<String> imageCredits;
  final List<String> tags;
  final bool isFavorite;
  final bool isFeatured;
  final bool isTrending;
  final bool verified;

  const PlaceModel({
    required this.id,
    required this.name,
    required this.city,
    required this.category,
    required this.shortDescription,
    required this.description,
    required this.whyVisit,
    required this.bestTimeToVisit,
    required this.estimatedDuration,
    required this.priceInfo,
    required this.latitude,
    required this.longitude,
    required this.images,
    this.imageCredits = const [],
    required this.tags,
    this.isFavorite = false,
    this.isFeatured = false,
    this.isTrending = false,
    this.verified = false,
  });

  String get heroImage => images.isNotEmpty ? images.first : '';

  String get distance => city;

  Map<String, double> get coordinates => {
        'lat': latitude,
        'lng': longitude,
      };

  factory PlaceModel.fromJson(Map<String, dynamic> json) {
    return PlaceModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      city: json['city'] as String? ?? '',
      category: json['category'] as String? ?? '',
      shortDescription: json['shortDescription'] as String? ?? '',
      description: json['description'] as String? ?? '',
      whyVisit: json['whyVisit'] as String? ?? '',
      bestTimeToVisit: json['bestTimeToVisit'] as String? ?? '',
      estimatedDuration: json['estimatedDuration'] as String? ?? '',
      priceInfo: json['priceInfo'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      imageCredits: (json['imageCredits'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      isFavorite: json['isFavorite'] as bool? ?? false,
      isFeatured: json['isFeatured'] as bool? ?? false,
      isTrending: json['isTrending'] as bool? ?? false,
      verified: json['verified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'city': city,
      'category': category,
      'shortDescription': shortDescription,
      'description': description,
      'whyVisit': whyVisit,
      'bestTimeToVisit': bestTimeToVisit,
      'estimatedDuration': estimatedDuration,
      'priceInfo': priceInfo,
      'latitude': latitude,
      'longitude': longitude,
      'images': images,
      'imageCredits': imageCredits,
      'tags': tags,
      'isFavorite': isFavorite,
      'isFeatured': isFeatured,
      'isTrending': isTrending,
      'verified': verified,
    };
  }

  PlaceModel copyWith({
    String? id,
    String? name,
    String? city,
    String? category,
    String? shortDescription,
    String? description,
    String? whyVisit,
    String? bestTimeToVisit,
    String? estimatedDuration,
    String? priceInfo,
    double? latitude,
    double? longitude,
    List<String>? images,
    List<String>? imageCredits,
    List<String>? tags,
    bool? isFavorite,
    bool? isFeatured,
    bool? isTrending,
    bool? verified,
  }) {
    return PlaceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      city: city ?? this.city,
      category: category ?? this.category,
      shortDescription: shortDescription ?? this.shortDescription,
      description: description ?? this.description,
      whyVisit: whyVisit ?? this.whyVisit,
      bestTimeToVisit: bestTimeToVisit ?? this.bestTimeToVisit,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      priceInfo: priceInfo ?? this.priceInfo,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      images: images ?? this.images,
      imageCredits: imageCredits ?? this.imageCredits,
      tags: tags ?? this.tags,
      isFavorite: isFavorite ?? this.isFavorite,
      isFeatured: isFeatured ?? this.isFeatured,
      isTrending: isTrending ?? this.isTrending,
      verified: verified ?? this.verified,
    );
  }
}
