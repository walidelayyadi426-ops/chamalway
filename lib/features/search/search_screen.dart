import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/place_card.dart';
import '../../data/repositories/destination_repository.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final List<String> _recentSearches = [
    'Akchour Waterfalls',
    'Chefchaouen',
    'Tangier Seafood',
    'Dalia Beach',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final repo = ref.watch(destinationRepositoryProvider);
    final results = repo.searchPlaces(_searchQuery);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Search Header Bar with Filter & Voice trigger
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.cardDark : Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) {
                          setState(() => _searchQuery = val);
                        },
                        decoration: InputDecoration(
                          hintText: 'Search places, beaches, foods...',
                          icon: const Icon(Icons.search, color: AppColors.primary),
                          border: InputBorder.none,
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 20),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Filter Modal Trigger Button
                  GestureDetector(
                    onTap: () => _showFilterBottomSheet(context),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(Icons.tune, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            // Recent Searches Chips
            if (_searchQuery.isEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent Searches',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() => _recentSearches.clear());
                      },
                      child: const Text('Clear All',
                          style: TextStyle(color: Colors.grey)),
                    ),
                  ],
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: _recentSearches.map((term) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ActionChip(
                        label: Text(term),
                        avatar: const Icon(Icons.history, size: 16),
                        onPressed: () {
                          _searchController.text = term;
                          setState(() => _searchQuery = term);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const Divider(height: 32),
            ],

            // Search Results List
            Expanded(
              child: results.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off,
                              size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 12),
                          Text(
                            'No places found for "$_searchQuery"',
                            style: const TextStyle(
                                fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        final place = results[index];
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
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filter Destinations',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: const [
                  Chip(label: Text('📍 Near Me (Within 10 km)')),
                  Chip(label: Text('⭐ Top Rated (4.8+)')),
                  Chip(label: Text('🕒 Open Now')),
                  Chip(label: Text('💰 Budget Friendly')),
                  Chip(label: Text('💎 Luxury')),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Apply Filters',
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
