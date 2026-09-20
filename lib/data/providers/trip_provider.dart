import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TripState {
  final int daysCount;
  final Map<int, List<String>> dayPlaces; // Key: day number (1..daysCount), Value: list of place IDs

  const TripState({
    this.daysCount = 3,
    this.dayPlaces = const {
      1: [],
      2: [],
      3: [],
    },
  });

  int get totalPlacesCount =>
      dayPlaces.values.fold(0, (sum, list) => sum + list.length);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> daysJson = {};
    dayPlaces.forEach((day, list) {
      daysJson[day.toString()] = list;
    });
    return {
      'daysCount': daysCount,
      'days': daysJson,
    };
  }

  factory TripState.fromJson(Map<String, dynamic> json) {
    final daysCount = json['daysCount'] as int? ?? 3;
    final Map<int, List<String>> dayPlaces = {};
    final daysJson = json['days'] as Map<String, dynamic>? ?? {};

    for (int i = 1; i <= daysCount; i++) {
      final rawList = daysJson[i.toString()] as List<dynamic>?;
      dayPlaces[i] = rawList?.map((e) => e.toString()).toList() ?? [];
    }

    // Preserve any overflow days if saved daysCount was larger
    daysJson.forEach((key, value) {
      final dayNum = int.tryParse(key);
      if (dayNum != null && dayNum > daysCount && value is List) {
        final overflowList = value.map((e) => e.toString()).toList();
        final currentLast = dayPlaces[daysCount] ?? [];
        for (final p in overflowList) {
          if (!currentLast.contains(p)) {
            currentLast.add(p);
          }
        }
        dayPlaces[daysCount] = currentLast;
      }
    });

    return TripState(
      daysCount: daysCount,
      dayPlaces: dayPlaces,
    );
  }

  TripState copyWith({
    int? daysCount,
    Map<int, List<String>>? dayPlaces,
  }) {
    return TripState(
      daysCount: daysCount ?? this.daysCount,
      dayPlaces: dayPlaces ?? this.dayPlaces,
    );
  }
}

class TripNotifier extends StateNotifier<TripState> {
  static const String _storageKey = 'my_trip_data_v1';
  final SharedPreferences? _prefs;

  TripNotifier([this._prefs]) : super(const TripState()) {
    _loadFromPrefs();
  }

  void _loadFromPrefs() {
    if (_prefs == null) return;
    final rawJson = _prefs.getString(_storageKey);
    if (rawJson != null && rawJson.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawJson) as Map<String, dynamic>;
        state = TripState.fromJson(decoded);
      } catch (_) {
        // Fallback to default state on parse error
      }
    }
  }

  Future<void> _saveToPrefs() async {
    if (_prefs == null) return;
    final rawJson = jsonEncode(state.toJson());
    await _prefs.setString(_storageKey, rawJson);
  }

  /// Adds a place to a specific day (1-indexed).
  /// Returns false if place already exists in that day.
  bool addPlaceToDay(String placeId, int dayNumber) {
    if (dayNumber < 1 || dayNumber > state.daysCount) return false;

    final currentDayList = List<String>.from(state.dayPlaces[dayNumber] ?? []);

    // Prevent duplicate addition in the same day
    if (currentDayList.contains(placeId)) {
      return false;
    }

    currentDayList.add(placeId);

    final newDayPlaces = Map<int, List<String>>.from(state.dayPlaces);
    newDayPlaces[dayNumber] = currentDayList;

    state = state.copyWith(dayPlaces: newDayPlaces);
    _saveToPrefs();
    return true;
  }

  /// Removes a place from a specific day.
  void removePlaceFromDay(String placeId, int dayNumber) {
    if (!state.dayPlaces.containsKey(dayNumber)) return;

    final currentDayList = List<String>.from(state.dayPlaces[dayNumber] ?? []);
    currentDayList.remove(placeId);

    final newDayPlaces = Map<int, List<String>>.from(state.dayPlaces);
    newDayPlaces[dayNumber] = currentDayList;

    state = state.copyWith(dayPlaces: newDayPlaces);
    _saveToPrefs();
  }

  /// Reorders items within a specific day.
  void reorderDayPlaces(int dayNumber, int oldIndex, int newIndex) {
    if (!state.dayPlaces.containsKey(dayNumber)) return;

    final currentDayList = List<String>.from(state.dayPlaces[dayNumber] ?? []);
    if (oldIndex < 0 || oldIndex >= currentDayList.length) return;
    if (newIndex < 0 || newIndex >= currentDayList.length) return;

    final item = currentDayList.removeAt(oldIndex);
    currentDayList.insert(newIndex, item);

    final newDayPlaces = Map<int, List<String>>.from(state.dayPlaces);
    newDayPlaces[dayNumber] = currentDayList;

    state = state.copyWith(dayPlaces: newDayPlaces);
    _saveToPrefs();
  }

  /// Updates the total number of days (1 to 7).
  /// If reducing days, moves places from removed days to the last remaining day without silent deletion.
  void setDaysCount(int newDaysCount) {
    if (newDaysCount < 1 || newDaysCount > 7 || newDaysCount == state.daysCount) return;

    final Map<int, List<String>> newDayPlaces = {};

    if (newDaysCount < state.daysCount) {
      final List<String> placesToMigrate = [];
      state.dayPlaces.forEach((day, places) {
        if (day <= newDaysCount) {
          newDayPlaces[day] = List<String>.from(places);
        } else {
          placesToMigrate.addAll(places);
        }
      });

      final lastDayPlaces = List<String>.from(newDayPlaces[newDaysCount] ?? []);
      for (final pId in placesToMigrate) {
        if (!lastDayPlaces.contains(pId)) {
          lastDayPlaces.add(pId);
        }
      }
      newDayPlaces[newDaysCount] = lastDayPlaces;
    } else {
      for (int i = 1; i <= newDaysCount; i++) {
        newDayPlaces[i] = List<String>.from(state.dayPlaces[i] ?? []);
      }
    }

    state = TripState(
      daysCount: newDaysCount,
      dayPlaces: newDayPlaces,
    );
    _saveToPrefs();
  }

  /// Clears all trip data.
  void clearTrip() {
    state = const TripState();
    _saveToPrefs();
  }
}

final sharedPreferencesProvider = Provider<SharedPreferences?>((ref) => null);

final tripProvider = StateNotifierProvider<TripNotifier, TripState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return TripNotifier(prefs);
});
