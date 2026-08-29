import 'package:flutter/material.dart';
import '../models/place_model.dart';
import '../models/category_model.dart';
import '../models/review_model.dart';

class MoroccoDummyData {
  static const List<CategoryModel> categories = [
    CategoryModel(
      id: 'beaches',
      title: 'Beaches',
      icon: Icons.beach_access,
      imageBg: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e',
      count: 14,
    ),
    CategoryModel(
      id: 'mountains',
      title: 'Mountains',
      icon: Icons.landscape,
      imageBg: 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b',
      count: 9,
    ),
    CategoryModel(
      id: 'history',
      title: 'History',
      icon: Icons.account_balance,
      imageBg: 'https://images.unsplash.com/photo-1548013146-72479768bada',
      count: 18,
    ),
    CategoryModel(
      id: 'restaurants',
      title: 'Restaurants',
      icon: Icons.restaurant,
      imageBg: 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4',
      count: 25,
    ),
    CategoryModel(
      id: 'cafes',
      title: 'Cafés',
      icon: Icons.local_cafe,
      imageBg: 'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb',
      count: 31,
    ),
    CategoryModel(
      id: 'hotels',
      title: 'Hotels',
      icon: Icons.hotel,
      imageBg: 'https://images.unsplash.com/photo-1566073771259-6a8506099945',
      count: 16,
    ),
    CategoryModel(
      id: 'shopping',
      title: 'Shopping',
      icon: Icons.shopping_bag,
      imageBg: 'https://images.unsplash.com/photo-1555529669-e69e7aa0ba9a',
      count: 12,
    ),
  ];

  static final List<PlaceModel> places = [
    const PlaceModel(
      id: 'chefchaouen_medina',
      name: 'Chefchaouen Blue Medina',
      city: 'Chefchaouen',
      category: 'history',
      rating: 4.9,
      reviewCount: 1420,
      distance: '1.2 km from city center',
      priceRange: 'Free Access',
      heroImage: 'https://images.unsplash.com/photo-1548013146-72479768bada?w=1000',
      gallery: [
        'https://images.unsplash.com/photo-1548013146-72479768bada?w=800',
        'https://images.unsplash.com/photo-1565008447742-97f6f38c985c?w=800',
        'https://images.unsplash.com/photo-1539037116277-4db20889f2d4?w=800',
      ],
      description:
          'Chefchaouen is famous for its striking blue-washed buildings nestled in the Rif Mountains. Stroll through narrow cobblestone alleys adorned with colorful pottery, handwoven blankets, and blooming plant pots.',
      history:
          'Founded in 1471 by Moulay Ali Ben Rachid as a small fortress against Portuguese invasions, Chefchaouen grew rapidly with Sephardic Jewish and Moorish refugees fleeing Spain.',
      openHours: '24 Hours Open',
      phone: '+212 539 986 211',
      coordinates: {'lat': 35.1713, 'lng': -5.2697},
      tags: ['Blue City', 'Unesco Candidate', 'Photography', 'Handicrafts'],
      isFeatured: true,
      isTrending: true,
      isFavorite: true,
    ),
    const PlaceModel(
      id: 'akchour_waterfalls',
      name: 'Akchour Waterfalls & God’s Bridge',
      city: 'Akchour',
      category: 'mountains',
      rating: 4.8,
      reviewCount: 980,
      distance: '30 km from Chefchaouen',
      priceRange: 'Free Nature Reserve',
      heroImage: 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=1000',
      gallery: [
        'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=800',
        'https://images.unsplash.com/photo-1432405972618-c60b0225b8f9?w=800',
      ],
      description:
          'A spectacular natural canyon with emerald natural pools, lush green foliage, towering cliff walls, and the iconic limestone rock arch known as God’s Bridge.',
      history:
          'Formed over thousands of years by the erosion of the Farda River in the Talassemtane National Park, Akchour remains a sanctuary for native Moroccan flora and wildlife.',
      openHours: '07:00 AM - 07:00 PM',
      phone: '+212 539 987 100',
      coordinates: {'lat': 35.2241, 'lng': -5.1764},
      tags: ['Hiking', 'Waterfalls', 'Natural Arch', 'Swimming'],
      isFeatured: true,
      isTrending: true,
    ),
    const PlaceModel(
      id: 'caves_of_hercules',
      name: 'Caves of Hercules (Les Grottes d’Hercule)',
      city: 'Tangier',
      category: 'history',
      rating: 4.7,
      reviewCount: 1650,
      distance: '14 km from Tangier Center',
      priceRange: '10 MAD Entry',
      heroImage: 'https://images.unsplash.com/photo-1539037116277-4db20889f2d4?w=1000',
      gallery: [
        'https://images.unsplash.com/photo-1539037116277-4db20889f2d4?w=800',
        'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800',
      ],
      description:
          'An archaeological cave complex situated right on the Atlantic coast. The sea opening resembles an inverted map of Africa, making it one of Tangier’s most iconic landmarks.',
      history:
          'Greek mythology claims Hercules rested in this cave before performing his 11th labor of obtaining golden apples from the Hesperides. The cave combines natural and man-made millstone quarrying.',
      openHours: '09:00 AM - 08:00 PM',
      phone: '+212 539 331 012',
      coordinates: {'lat': 35.7597, 'lng': -5.9392},
      tags: ['Mythology', 'Sea View', 'Archaeology', 'Tangier Icon'],
      isFeatured: true,
      isTrending: true,
    ),
    const PlaceModel(
      id: 'dalia_beach',
      name: 'Plage Dalia',
      city: 'Tangier / Belyounech',
      category: 'beaches',
      rating: 4.9,
      reviewCount: 750,
      distance: '45 km from Tangier',
      priceRange: 'Free Public Beach',
      heroImage: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=1000',
      gallery: [
        'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800',
        'https://images.unsplash.com/photo-1519046904884-53103b34b206?w=800',
      ],
      description:
          'Crystal-clear turquoise waters and soft golden sand overlooking the Gibraltar Strait. Dalia Beach is renowned for its tranquil atmosphere and fresh local grilled fish stalls.',
      history:
          'Historically a quiet fishing hamlet, Dalia was awarded the Blue Flag for clean waters and has become one of the top Mediterranean beaches in Northern Africa.',
      openHours: '24 Hours Open',
      phone: '+212 539 941 220',
      coordinates: {'lat': 35.8942, 'lng': -5.4611},
      tags: ['Crystal Waters', 'Blue Flag', 'Seafood', 'Relaxation'],
      isFeatured: true,
      isTrending: false,
      isFavorite: true,
    ),
    const PlaceModel(
      id: 'martil_beach_promenade',
      name: 'Martil Beach & Corniche',
      city: 'Martil',
      category: 'beaches',
      rating: 4.6,
      reviewCount: 1100,
      distance: '10 km from Tetouan',
      priceRange: 'Free Access',
      heroImage: 'https://images.unsplash.com/photo-1519046904884-53103b34b206?w=1000',
      gallery: [
        'https://images.unsplash.com/photo-1519046904884-53103b34b206?w=800',
      ],
      description:
          'A vibrant coastal town boasting a wide palm-lined promenade, golden sandy beaches, lively summer festivals, and sea-view ice cream parlors.',
      history:
          'Martil served as Tetouan’s main maritime port during the Spanish protectorate era and remains the favorite seaside escape for domestic and international travelers.',
      openHours: '24 Hours Open',
      phone: '+212 539 979 010',
      coordinates: {'lat': 35.6174, 'lng': -5.2678},
      tags: ['Corniche', 'Nightlife', 'Family Friendly', 'Water Sports'],
      isFeatured: false,
      isTrending: true,
    ),
    const PlaceModel(
      id: 'le_miramar_restaurant',
      name: 'Le Miramar Seafood Restaurant',
      city: 'Tangier',
      category: 'restaurants',
      rating: 4.8,
      reviewCount: 620,
      distance: '0.8 km from Port',
      priceRange: '\$\$ - Luxury Dining',
      heroImage: 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=1000',
      gallery: [
        'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800',
      ],
      description:
          'Premier oceanfront dining serving daily catches of wild Mediterranean sea bass, king prawns, seafood pastilla, and traditional saffron rice.',
      history:
          'Serving diners since 1982 with classic Andalusian-Moroccan hospitality and panoramic views of the Bay of Tangier.',
      openHours: '12:00 PM - 11:30 PM',
      phone: '+212 539 932 444',
      coordinates: {'lat': 35.7865, 'lng': -5.8080},
      tags: ['Seafood', 'Sea View', 'Fine Dining', 'Pastilla'],
      isFeatured: true,
      isTrending: true,
    ),
    const PlaceModel(
      id: 'quemado_beach_alhoceima',
      name: 'Plage Quemado (Al Hoceima)',
      city: 'Al Hoceima',
      category: 'beaches',
      rating: 4.9,
      reviewCount: 890,
      distance: 'City Coast',
      priceRange: 'Free Public Beach',
      heroImage: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=1000',
      gallery: [
        'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800',
      ],
      description:
          'Framed by majestic limestone cliffs, Quemado Beach offers azure waters, jet-ski rentals, scuba diving expeditions, and luxury resort amenities.',
      history:
          'Located in the heart of the Rif coastal region, Al Hoceima’s Quemado Bay is celebrated as the Pearl of the Moroccan Mediterranean.',
      openHours: '24 Hours Open',
      phone: '+212 539 982 050',
      coordinates: {'lat': 35.2472, 'lng': -3.9317},
      tags: ['Cliffside', 'Jet Ski', 'Mediterranean', 'Resort'],
      isFeatured: true,
      isTrending: true,
    ),
  ];

  static const List<ReviewModel> sampleReviews = [];
}
