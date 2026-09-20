import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/place_card.dart';
import '../../core/widgets/empty_state.dart';
import '../../data/repositories/destination_repository.dart';
import '../../data/models/place_model.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
  String _searchQuery = '';
  String _selectedCity = 'all';
  String _selectedCategory = 'all';

  final List<String> _recentSearches = [
    'Chefchaouen',
    'Akchour',
    'Tangier',
    'Martil',
    'Al Hoceima',
  ];

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _searchQuery = query;
        });
      }
    });
  }

  List<PlaceModel> _filterPlaces(List<PlaceModel> places) {
    return places.where((place) {
      if (_selectedCity != 'all' &&
          place.city.toLowerCase() != _selectedCity.toLowerCase()) {
        return false;
      }
      if (_selectedCategory != 'all' &&
          place.category.toLowerCase() != _selectedCategory.toLowerCase()) {
        return false;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final repo = ref.watch(destinationRepositoryProvider);

    final rawResults = repo.searchPlaces(_searchQuery);
    final results = _filterPlaces(rawResults);
    final availableCities = repo.getAvailableCities();
    final availableCategories = repo.getAvailableCategories();

    final bool hasActiveFilters =
        _selectedCity != 'all' || _selectedCategory != 'all';

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Search Header Bar
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
                        onChanged: _onSearchChanged,
                        decoration: InputDecoration(
                          hintText: 'Search places, cities, tags...',
                          icon: const Icon(Icons.search, color: AppColors.primary),
                          border: InputBorder.none,
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 20),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchQuery = '';
                                    });
                                  },
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
                  if (hasActiveFilters) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.filter_alt_off, color: Colors.red),
                      tooltip: 'Reset Filters',
                      onPressed: () {
                        setState(() {
                          _selectedCity = 'all';
                          _selectedCategory = 'all';
                        });
                      },
                    ),
                  ],
                ],
              ),
            ),

            // Horizontal Category Chips
            if (availableCategories.isNotEmpty)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    ChoiceChip(
                      selected: _selectedCategory == 'all',
                      label: const Text('🌟 All Categories'),
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: _selectedCategory == 'all'
                            ? Colors.white
                            : AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                      onSelected: (_) {
                        setState(() => _selectedCategory = 'all');
                      },
                    ),
                    const SizedBox(width: 8),
                    ...availableCategories.map((cat) {
                      final isSelected = _selectedCategory == cat.id;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          selected: isSelected,
                          label: Text(cat.title),
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : AppColors.primary,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          onSelected: (_) {
                            setState(() => _selectedCategory = cat.id);
                          },
                        ),
                      );
                    }),
                  ],
                ),
              ),

            // Horizontal City Selector Chips
            if (availableCities.isNotEmpty) ...[
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Icon(Icons.location_city,
                        size: 16, color: Colors.grey),
                    const SizedBox(width: 6),
                    ChoiceChip(
                      selected: _selectedCity == 'all',
                      label: const Text('All Cities'),
                      selectedColor: AppColors.secondary,
                      labelStyle: TextStyle(
                        color: _selectedCity == 'all'
                            ? Colors.white
                            : (isDark ? Colors.white70 : Colors.black87),
                        fontSize: 12,
                      ),
                      onSelected: (_) {
                        setState(() => _selectedCity = 'all');
                      },
                    ),
                    const SizedBox(width: 6),
                    ...availableCities.map((city) {
                      final isSelected =
                          _selectedCity.toLowerCase() == city.toLowerCase();
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          selected: isSelected,
                          label: Text(city),
                          selectedColor: AppColors.secondary,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : (isDark ? Colors.white70 : Colors.black87),
                            fontSize: 12,
                          ),
                          onSelected: (_) {
                            setState(() => _selectedCity = city);
                          },
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 10),

            // Recent Searches Chips
            if (_searchQuery.isEmpty && !hasActiveFilters) ...[
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Popular Searches',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
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
                        avatar: const Icon(Icons.history, size: 14),
                        onPressed: () {
                          _searchController.text = term;
                          setState(() => _searchQuery = term);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const Divider(height: 24),
            ],

            // Results List or Empty State
            Expanded(
              child: results.isEmpty
                  ? EmptyState(
                      title: 'No Destinations Found',
                      message: _searchQuery.isNotEmpty
                          ? 'No destinations match "$_searchQuery". Try searching for another city, tag, or landmark.'
                          : 'No destinations match your selected filters.',
                      icon: Icons.search_off_rounded,
                      actionLabel: hasActiveFilters ? 'Clear Filters' : null,
                      onAction: hasActiveFilters
                          ? () {
                              setState(() {
                                _selectedCity = 'all';
                                _selectedCategory = 'all';
                                _searchController.clear();
                                _searchQuery = '';
                              });
                            }
                          : null,
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
}
