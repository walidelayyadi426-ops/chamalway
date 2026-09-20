// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

const int kMinPlacesPerCategory = 6;
const double kMinLat = 34.0;
const double kMaxLat = 36.0;
const double kMinLng = -7.0;
const double kMaxLng = -2.0;

void main() async {
  final file = File('assets/data/places.json');
  if (!file.existsSync()) {
    print('Error: assets/data/places.json not found!');
    exit(1);
  }

  final jsonString = await file.readAsString();
  final List<dynamic> rawList = jsonDecode(jsonString);

  final List<Map<String, dynamic>> places =
      rawList.map((e) => Map<String, dynamic>.from(e)).toList();

  final Map<String, List<Map<String, dynamic>>> categoriesMap = {};
  final Map<String, List<String>> coordToPlaceIdsMap = {};
  final List<String> outOfBoundsPlaces = [];
  final List<String> verifiedExternalImageWarnings = [];

  for (final place in places) {
    final cat = (place['category'] as String? ?? 'Unknown');
    categoriesMap.putIfAbsent(cat, () => []).add(place);

    final id = place['id'] as String? ?? 'unknown';
    final lat = (place['latitude'] as num?)?.toDouble() ?? 0.0;
    final lng = (place['longitude'] as num?)?.toDouble() ?? 0.0;
    final isVerified = place['verified'] as bool? ?? false;
    final images = (place['images'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];

    // Check bounds
    if (lat < kMinLat || lat > kMaxLat || lng < kMinLng || lng > kMaxLng) {
      outOfBoundsPlaces.add('$id (Lat: $lat, Lng: $lng)');
    }

    // Check duplicate coordinates
    final coordKey = '${lat.toStringAsFixed(6)},${lng.toStringAsFixed(6)}';
    coordToPlaceIdsMap.putIfAbsent(coordKey, () => []).add(id);

    // Check verified places using external network image URLs
    if (isVerified) {
      for (final img in images) {
        if (img.startsWith('http://') || img.startsWith('https://')) {
          verifiedExternalImageWarnings.add('$id uses external URL ($img)');
        }
      }
    }
  }

  print('\n==================================================');
  print('       CHAMALWAY CONTENT AUDIT & REPORT           ');
  print('==================================================\n');

  int totalPlacesAll = places.length;
  int totalVerifiedAll = 0;
  int totalVerifiedWithPhotoAll = 0;
  int categoriesVisibleInRelease = 0;

  categoriesMap.forEach((category, catPlaces) {
    int catTotal = catPlaces.length;
    int catVerified = 0;
    int catVerifiedWithPhoto = 0;
    final List<String> missingItems = [];

    for (final p in catPlaces) {
      final id = p['id'] as String? ?? 'unknown';
      final isVerified = p['verified'] as bool? ?? false;
      final images = (p['images'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
      final hasPhoto = images.isNotEmpty && images.first.trim().isNotEmpty;

      final lat = (p['latitude'] as num?)?.toDouble() ?? 0.0;
      final lng = (p['longitude'] as num?)?.toDouble() ?? 0.0;
      final validCoords = (lat >= kMinLat && lat <= kMaxLat && lng >= kMinLng && lng <= kMaxLng);

      if (isVerified) catVerified++;
      if (isVerified && hasPhoto) catVerifiedWithPhoto++;

      final List<String> reasons = [];
      if (!isVerified) reasons.add('UNVERIFIED');
      if (!hasPhoto) reasons.add('NO PHOTO');
      if (!validCoords) reasons.add('INVALID COORDS ($lat, $lng)');

      if (reasons.isNotEmpty) {
        missingItems.add('$id (${reasons.join(', ')})');
      }
    }

    totalVerifiedAll += catVerified;
    totalVerifiedWithPhotoAll += catVerifiedWithPhoto;

    final bool isCategoryVisible = catVerifiedWithPhoto >= kMinPlacesPerCategory;
    if (isCategoryVisible) {
      categoriesVisibleInRelease++;
    }

    print('Category: [$category]');
    print('  - Total Places:                $catTotal');
    print('  - Verified Places:             $catVerified');
    print('  - Verified w/ Photo (Release): $catVerifiedWithPhoto');
    print('  - Release Chip Visible:        ${isCategoryVisible ? "YES ✅" : "NO ❌ (Need ${kMinPlacesPerCategory - catVerifiedWithPhoto} more verified photo places)"}');

    if (missingItems.isNotEmpty) {
      print('  - Places Needing Attention (${missingItems.length}):');
      for (final item in missingItems) {
        print('      * $item');
      }
    }
    print('');
  });

  print('--------------------------------------------------');
  print('GEOGRAPHIC & COORDINATE AUDIT:');

  if (outOfBoundsPlaces.isEmpty) {
    print('  - Out-of-bounds Coordinates (Northern Morocco 34-36°N, -7 to -2°E): None ✅');
  } else {
    print('  - Out-of-bounds Coordinates (${outOfBoundsPlaces.length}): ❌');
    for (final item in outOfBoundsPlaces) {
      print('      * $item');
    }
  }

  final duplicateCoordsMap = Map.fromEntries(
      coordToPlaceIdsMap.entries.where((entry) => entry.value.length > 1));

  if (duplicateCoordsMap.isEmpty) {
    print('  - Duplicate Coordinates: None ✅');
  } else {
    print('  - Duplicate Coordinates (${duplicateCoordsMap.length} duplicate groups): ❌');
    duplicateCoordsMap.forEach((coord, placeIds) {
      print('      * Coords ($coord): ${placeIds.join(', ')}');
    });
  }

  print('\n--------------------------------------------------');
  print('IMAGE ASSET AUDIT:');
  if (verifiedExternalImageWarnings.isEmpty) {
    print('  - Verified External Image Warnings: None (All verified places use local asset paths) ✅');
  } else {
    print('  - Verified External Image Warnings (${verifiedExternalImageWarnings.length}): ⚠️ (Recommend bundling local assets)');
    for (final warn in verifiedExternalImageWarnings) {
      print('      * $warn');
    }
  }

  print('\n--------------------------------------------------');
  print('SUMMARY OVERVIEW:');
  print('  - Total Places in JSON:        $totalPlacesAll');
  print('  - Total Verified Places:       $totalVerifiedAll');
  print('  - Total Release-Ready Places:  $totalVerifiedWithPhotoAll');
  print('  - Categories Visible in Release (kMin = $kMinPlacesPerCategory): $categoriesVisibleInRelease / ${categoriesMap.length}');
  print('==================================================\n');
}
