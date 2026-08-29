import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/place_card.dart';
import '../../data/repositories/destination_repository.dart';
import '../../data/models/place_model.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Set<String> _selectedFilters = {};
  final List<String> _recentSearches = [
    'Akchour Waterfalls',
    'Chefchaouen',
    'Tangier Seafood',
    'Dalia Beach',
  ];

  final Map<String, String> _filterOptions = const {
    'near_me': '📍 Near Me (Within 10 km)',
    'top_rated': '⭐ Top Rated (4.8+)',
    'open_now': '🕒 Open Now',
    'budget': '💰 Budget Friendly',
    'luxury': '💎 Luxury',
  };

  List<PlaceModel> _applyFilters(List<PlaceModel> places) {
    return places.where((place) {
      if (_selectedFilters.contains('near_me')) {
        if (place.distance.contains('km')) {
          final valStr = RegExp(r'[\d.]+').stringMatch(place.distance);
          if (valStr != null) {
            final val = double.tryParse(valStr);
            if (val != null && val > 10.0) return false;
          }
        }
      }
      if (_selectedFilters.contains('top_rated')) {
        if (place.rating < 4.8) return false;
      }
      if (_selectedFilters.contains('open_now')) {
        final hours = place.openHours.toLowerCase();
        if (!hours.contains('24 hours') && !hours.contains('09:00') && !hours.contains('07:00')) {
          return false;
        }
      }
      if (_selectedFilters.contains('budget')) {
        final price = place.priceRange.toLowerCase();
        if (!price.contains('free') && !price.contains('budget') && !price.contains('10 mad')) {
          return false;
        }
      }
      if (_selectedFilters.contains('luxury')) {
        final price = place.priceRange.toLowerCase();
        if (!price.contains('luxury') && !price.contains('\$\$')) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final repo = ref.watch(destinationRepositoryProvider);
    final rawResults = repo.searchPlaces(_searchQuery);
    final results = _applyFilters(rawResults);

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
                  // Filter Modal Trigger Button with Badge if active
                  GestureDetector(
                    onTap: () => _showFilterBottomSheet(context),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: _selectedFilters.isNotEmpty
                            ? AppColors.secondary
                            : AppColors.primary,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          const Icon(Icons.tune, color: Colors.white),
                          if (_selectedFilters.isNotEmpty)
                            Positioned(
                              top: -4,
                              right: -4,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '${_selectedFilters.length}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Active Filters Row
            if (_selectedFilters.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Text('Active Filters:',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            ..._selectedFilters.map((filterKey) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: Chip(
                                  label: Text(_filterOptions[filterKey] ?? filterKey,
                                      style: const TextStyle(fontSize: 11, color: Colors.white)),
                                  backgroundColor: AppColors.primary,
                                  deleteIcon: const Icon(Icons.close, size: 14, color: Colors.white),
                                  onDeleted: () {
                                    setState(() {
                                      _selectedFilters.remove(filterKey);
                                    });
                                  },
                                ),
                              );
                            }),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _selectedFilters.clear();
                                });
                              },
                              child: const Text('Clear All',
                                  style: TextStyle(fontSize: 12, color: Colors.red)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],

            // Recent Searches Chips
            if (_searchQuery.isEmpty && _selectedFilters.isEmpty) ...[
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
                            _selectedFilters.isNotEmpty
                                ? 'No places found matching selected filters'
                                : 'No places found for "$_searchQuery"',
                            style: const TextStyle(
                                fontSize: 16, color: Colors.grey),
                          ),
                          if (_selectedFilters.isNotEmpty)
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _selectedFilters.clear();
                                });
                              },
                              child: const Text('Reset Filters'),
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
    final tempFilters = Set<String>.from(_selectedFilters);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Filter Destinations',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        if (tempFilters.isNotEmpty)
                          TextButton(
                            onPressed: () {
                              setSheetState(() {
                                tempFilters.clear();
                              });
                            },
                            child: const Text('Reset',
                                style: TextStyle(color: Colors.red)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _filterOptions.entries.map((entry) {
                        final key = entry.key;
                        final label = entry.value;
                        final isSelected = tempFilters.contains(key);

                        return FilterChip(
                          selected: isSelected,
                          label: Text(label),
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : (isDark ? Colors.white70 : Colors.black87),
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          selectedColor: AppColors.primary,
                          checkmarkColor: Colors.white,
                          backgroundColor:
                              isDark ? Colors.grey[800] : Colors.grey[200],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          onSelected: (selected) {
                            setSheetState(() {
                              if (selected) {
                                tempFilters.add(key);
                              } else {
                                tempFilters.remove(key);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedFilters = Set.from(tempFilters);
                          });
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text('Apply Filters',
                            style:
                                TextStyle(color: Colors.white, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
