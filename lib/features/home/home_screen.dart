import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/place_card.dart';
import '../../core/widgets/empty_state.dart';
import '../../data/repositories/destination_repository.dart';


class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late PageController _carouselController;
  int _currentCarouselIndex = 0;
  Timer? _carouselTimer;

  final List<Map<String, dynamic>> _featuredCities = [
    {
      'city': 'Chefchaouen',
      'title': 'The Blue Pearl of Morocco',
      'icon': Icons.account_balance_rounded,
      'image': 'assets/images/places/chefchaouen_medina_1.jpg',
      'gradient': const [Color(0xFF1E88E5), Color(0xFF0D47A1)],
    },
    {
      'city': 'Tangier',
      'title': 'Bride of the North & Gateway to Africa',
      'icon': Icons.waves_rounded,
      'image': 'assets/images/places/kasbah_museum_tangier_1.jpg',
      'gradient': const [Color(0xFF00897B), Color(0xFF004D40)],
    },
    {
      'city': 'Akchour',
      'title': 'Enchanted Waterfalls & Mountains',
      'icon': Icons.landscape_rounded,
      'image': 'assets/images/places/akchour_waterfalls_1.jpg',
      'gradient': const [Color(0xFF43A047), Color(0xFF1B5E20)],
    },
    {
      'city': 'Al Hoceima',
      'title': 'Mediterranean Sapphire Coast',
      'icon': Icons.beach_access_rounded,
      'image': 'assets/images/places/quemado_beach_alhoceima_1.jpg',
      'gradient': const [Color(0xFF0288D1), Color(0xFF01579B)],
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
    final availableCategories = repo.getAvailableCategories();
    final filteredPlaces = repo.getPlacesByCategory(selectedCategory);
    final allPlaces = repo.getAllPlaces();

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header: Greeting & Notifications
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Salam! Explore the North 🇲🇦',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
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
                        IconButton(
                          icon: const Icon(Icons.settings_outlined),
                          onPressed: () => context.push('/settings'),
                        ),
                      ],
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
                            'Search beaches, mountains, cafes...',
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
                      'Featured Destinations',
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
                        final colors = city['gradient'] as List<Color>;
                        final iconData = city['icon'] as IconData;
                        final imagePath = city['image'] as String?;

                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                // Background Photo or Gradient Fallback
                                if (imagePath != null)
                                  Image.asset(
                                    imagePath,
                                    fit: BoxFit.cover,
                                    errorBuilder: (ctx, err, stack) =>
                                        Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: colors,
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                      ),
                                    ),
                                  )
                                else
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: colors,
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                    ),
                                  ),

                                // Dark Gradient Protection Overlay for ultra contrast & readability
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.black.withValues(alpha: 0.15),
                                        Colors.black.withValues(alpha: 0.75),
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                ),

                                Positioned(
                                  right: -20,
                                  top: -20,
                                  child: Icon(
                                    iconData,
                                    size: 160,
                                    color: Colors.white.withValues(alpha: 0.15),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(iconData,
                                              color: AppColors.secondary,
                                              size: 24),
                                          const SizedBox(width: 8),
                                          Text(
                                            city['city'] as String,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        city['title'] as String,
                                        style: TextStyle(
                                          color: Colors.white.withValues(alpha: 0.95),
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

            // Categories Selector (only shown if availableCategories is not empty)
            if (availableCategories.isNotEmpty)
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
                          ...availableCategories.map((cat) {
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

            if (availableCategories.isNotEmpty)
              const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Trending Places Horizontal Slider
            if (trendingPlaces.isNotEmpty) ...[
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
            ],

            // Recommended Destinations List
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  availableCategories.isEmpty
                      ? 'All Destinations'
                      : (selectedCategory == 'all'
                          ? 'Recommended For You'
                          : 'Top ${selectedCategory.toUpperCase()}'),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 14)),

            // Render list safely
            if (allPlaces.isEmpty)
              SliverToBoxAdapter(
                child: EmptyState(
                  title: 'No Destinations Available',
                  message: 'No verified places are currently available.',
                  icon: Icons.explore_off_rounded,
                ),
              )
            else ...[
              () {
                final displayPlaces = availableCategories.isEmpty
                    ? allPlaces
                    : filteredPlaces;

                if (displayPlaces.isEmpty) {
                  return SliverToBoxAdapter(
                    child: EmptyState(
                      title: 'No Places Found',
                      message:
                          'No places match the selected category right now.',
                      onAction: () {
                        ref.read(selectedCategoryProvider.notifier).state =
                            'all';
                      },
                      actionLabel: 'Show All Places',
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final place = displayPlaces[index];
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
                      childCount: displayPlaces.length,
                    ),
                  ),
                );
              }(),
            ],

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
