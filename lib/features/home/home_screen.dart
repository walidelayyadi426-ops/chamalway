import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/place_card.dart';
import '../../data/repositories/destination_repository.dart';
import '../../data/datasource/morocco_dummy_data.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late PageController _carouselController;
  int _currentCarouselIndex = 0;
  Timer? _carouselTimer;

  final List<Map<String, String>> _featuredCities = [
    {
      'city': 'Chefchaouen',
      'title': 'The Blue Pearl of Morocco',
      'image':
          'https://images.unsplash.com/photo-1730581822492-8a55ce0b7fde?fm=jpg&q=60&w=1200&auto=format&fit=crop',
    },
    {
      'city': 'Tangier',
      'title': 'Bride of the North & Gateway to Africa',
      'image':
          'https://images.unsplash.com/photo-1682972443789-5ee7299bb2cb?fm=jpg&q=60&w=1200&auto=format&fit=crop',
    },
    {
      'city': 'Akchour',
      'title': 'Enchanted Waterfalls & Mountains',
      'image':
          'https://images.unsplash.com/photo-1432405972618-c60b0225b8f9?w=1000',
    },
    {
      'city': 'Al Hoceima',
      'title': 'Mediterranean Sapphire Coast',
      'image':
          'https://images.unsplash.com/photo-1506953823976-52e1fdc0149a?w=1000',
    },
  ];

  @override
  void initState() {
    super.initState();
    _carouselController = PageController(viewportFraction: 0.9);
    _carouselTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_carouselController.hasClients) {
        _currentCarouselIndex =
            (_currentCarouselIndex + 1) % _featuredCities.length;
        _carouselController.animateToPage(
          _currentCarouselIndex,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    _carouselController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final repo = ref.watch(destinationRepositoryProvider);
    final trendingPlaces = repo.getTrendingPlaces();
    final selectedCategory = ref.watch(selectedCategoryProvider);

    final filteredPlaces = repo.getPlacesByCategory(selectedCategory);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header: Location, Greeting, Live Weather & Notifications
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Location & Weather Pill
                        Row(
                          children: [
                            const Icon(Icons.near_me,
                                color: AppColors.primary, size: 20),
                            const SizedBox(width: 6),
                            const Text(
                              'Tangier, Morocco',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color:
                                    AppColors.secondary.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.wb_sunny,
                                      size: 14, color: AppColors.secondary),
                                  SizedBox(width: 4),
                                  Text(
                                    '26°C Sunny',
                                    style: TextStyle(
                                      color: AppColors.secondary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        // Notification Bell Icon
                        IconButton(
                          icon: const Icon(Icons.notifications_none_rounded),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('No new notifications'),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Salam! Explore the North 🇲🇦',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Floating Search Bar Trigger
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GestureDetector(
                  onTap: () => context.push('/explore'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDark : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withValues(alpha: isDark ? 0.3 : 0.06),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(
                        color: isDark
                            ? AppColors.glassBorderDark
                            : AppColors.glassBorderLight,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: AppColors.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Search beaches, mountains, restaurants...',
                            style: TextStyle(
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Featured Cities Carousel
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Featured Cities',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 180,
                    child: PageView.builder(
                      controller: _carouselController,
                      itemCount: _featuredCities.length,
                      onPageChanged: (idx) {
                        setState(() => _currentCarouselIndex = idx);
                      },
                      itemBuilder: (context, index) {
                        final city = _featuredCities[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                CachedNetworkImage(
                                  imageUrl: city['image']!,
                                  fit: BoxFit.cover,
                                ),
                                Container(
                                  decoration: const BoxDecoration(
                                    gradient: AppColors.heroOverlayGradient,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        city['city']!,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        city['title']!,
                                        style: const TextStyle(
                                          color: AppColors.secondary,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Categories Selector
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Categories',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        _buildCategoryChip(
                          ref: ref,
                          id: 'all',
                          label: '🌟 All',
                          isSelected: selectedCategory == 'all',
                        ),
                        ...MoroccoDummyData.categories.map((cat) {
                          return _buildCategoryChip(
                            ref: ref,
                            id: cat.id,
                            label: cat.title,
                            isSelected: selectedCategory == cat.id,
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Trending Places Horizontal Slider
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Trending Places',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.push('/explore'),
                          child: const Text('See All',
                              style: TextStyle(color: AppColors.primary)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 260,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.only(left: 20),
                      itemCount: trendingPlaces.length,
                      itemBuilder: (context, index) {
                        final place = trendingPlaces[index];
                        return PlaceCard(
                          place: place,
                          layout: CardLayout.horizontal,
                          onTap: () => context.push('/place/${place.id}'),
                          onFavoriteTap: () {
                            ref
                                .read(favoritesProvider.notifier)
                                .toggleFavorite(place.id);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Recommended Destinations List
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      selectedCategory == 'all'
                          ? 'Recommended For You'
                          : 'Top ${selectedCategory.toUpperCase()}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 14)),

            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final place = filteredPlaces[index];
                    return PlaceCard(
                      place: place,
                      layout: CardLayout.vertical,
                      onTap: () => context.push('/place/${place.id}'),
                      onFavoriteTap: () {
                        ref
                            .read(favoritesProvider.notifier)
                            .toggleFavorite(place.id);
                      },
                    );
                  },
                  childCount: filteredPlaces.length,
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip({
    required WidgetRef ref,
    required String id,
    required String label,
    required bool isSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Text(label),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppColors.primary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        ),
        selectedColor: AppColors.primary,
        backgroundColor: AppColors.primary.withValues(alpha: 0.08),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        onSelected: (_) {
          ref.read(selectedCategoryProvider.notifier).state = id;
        },
      ),
    );
  }
}
