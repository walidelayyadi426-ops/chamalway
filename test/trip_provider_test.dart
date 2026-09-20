import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chamalway/data/providers/trip_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;
  late TripNotifier tripNotifier;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    tripNotifier = TripNotifier(prefs);
  });

  group('TripNotifier Logic Tests', () {
    test('Initial state has 3 days and 0 total places', () {
      final state = tripNotifier.state;
      expect(state.daysCount, equals(3));
      expect(state.totalPlacesCount, equals(0));
      expect(state.dayPlaces[1], isEmpty);
      expect(state.dayPlaces[2], isEmpty);
      expect(state.dayPlaces[3], isEmpty);
    });

    test('Add place to day updates state and returns true', () {
      final success = tripNotifier.addPlaceToDay('chefchaouen_medina', 1);
      expect(success, isTrue);

      final state = tripNotifier.state;
      expect(state.dayPlaces[1], contains('chefchaouen_medina'));
      expect(state.totalPlacesCount, equals(1));
    });

    test('Prevent duplicate addition of same place to same day', () {
      final added1 = tripNotifier.addPlaceToDay('chefchaouen_medina', 1);
      final added2 = tripNotifier.addPlaceToDay('chefchaouen_medina', 1);

      expect(added1, isTrue);
      expect(added2, isFalse);

      final state = tripNotifier.state;
      expect(state.dayPlaces[1]!.length, equals(1));
    });

    test('Can add same place to different days', () {
      final addedDay1 = tripNotifier.addPlaceToDay('chefchaouen_medina', 1);
      final addedDay2 = tripNotifier.addPlaceToDay('chefchaouen_medina', 2);

      expect(addedDay1, isTrue);
      expect(addedDay2, isTrue);

      final state = tripNotifier.state;
      expect(state.dayPlaces[1], contains('chefchaouen_medina'));
      expect(state.dayPlaces[2], contains('chefchaouen_medina'));
      expect(state.totalPlacesCount, equals(2));
    });

    test('Remove place from day', () {
      tripNotifier.addPlaceToDay('chefchaouen_medina', 1);
      tripNotifier.addPlaceToDay('akchour_waterfalls', 1);

      tripNotifier.removePlaceFromDay('chefchaouen_medina', 1);

      final state = tripNotifier.state;
      expect(state.dayPlaces[1], isNot(contains('chefchaouen_medina')));
      expect(state.dayPlaces[1], contains('akchour_waterfalls'));
      expect(state.totalPlacesCount, equals(1));
    });

    test('Reorder places within a day', () {
      tripNotifier.addPlaceToDay('place1', 1);
      tripNotifier.addPlaceToDay('place2', 1);
      tripNotifier.addPlaceToDay('place3', 1);

      // Reorder item at index 0 ('place1') to index 2
      tripNotifier.reorderDayPlaces(1, 0, 2);

      final state = tripNotifier.state;
      expect(state.dayPlaces[1], equals(['place2', 'place3', 'place1']));
    });

    test('Reducing days count migrates overflow places to last remaining day without deletion', () {
      tripNotifier.setDaysCount(4);
      tripNotifier.addPlaceToDay('place1', 1);
      tripNotifier.addPlaceToDay('place2', 2);
      tripNotifier.addPlaceToDay('place3', 3);
      tripNotifier.addPlaceToDay('place4', 4);

      // Reduce days from 4 to 2
      tripNotifier.setDaysCount(2);

      final state = tripNotifier.state;
      expect(state.daysCount, equals(2));
      expect(state.dayPlaces[1], equals(['place1']));
      expect(state.dayPlaces[2], containsAll(['place2', 'place3', 'place4']));
      expect(state.totalPlacesCount, equals(4));
    });

    test('Reducing days count does not create duplicate entries in last remaining day', () {
      tripNotifier.setDaysCount(4);
      tripNotifier.addPlaceToDay('shared_place', 2);
      tripNotifier.addPlaceToDay('shared_place', 3);
      tripNotifier.addPlaceToDay('shared_place', 4);
      tripNotifier.addPlaceToDay('unique_place', 4);

      // Reduce days from 4 to 2
      tripNotifier.setDaysCount(2);

      final state = tripNotifier.state;
      expect(state.daysCount, equals(2));
      // 'shared_place' was in day 2, 3, 4. When migrating days 3 and 4 to day 2, 'shared_place' must appear exactly once in day 2
      expect(state.dayPlaces[2], equals(['shared_place', 'unique_place']));
      expect(state.dayPlaces[2]!.where((id) => id == 'shared_place').length, equals(1));
    });


    test('Expanding days count preserves existing places', () {
      tripNotifier.addPlaceToDay('place1', 1);
      tripNotifier.addPlaceToDay('place2', 2);

      tripNotifier.setDaysCount(5);

      final state = tripNotifier.state;
      expect(state.daysCount, equals(5));
      expect(state.dayPlaces[1], equals(['place1']));
      expect(state.dayPlaces[2], equals(['place2']));
      expect(state.dayPlaces[3], isEmpty);
      expect(state.dayPlaces[4], isEmpty);
      expect(state.dayPlaces[5], isEmpty);
    });

    test('Persistence across restarts via SharedPreferences', () async {
      tripNotifier.addPlaceToDay('chefchaouen_medina', 1);
      tripNotifier.addPlaceToDay('akchour_waterfalls', 2);

      // Instantiate new notifier reading from same shared preferences instance
      final newNotifier = TripNotifier(prefs);
      final reloadedState = newNotifier.state;

      expect(reloadedState.dayPlaces[1], contains('chefchaouen_medina'));
      expect(reloadedState.dayPlaces[2], contains('akchour_waterfalls'));
      expect(reloadedState.totalPlacesCount, equals(2));
    });

    test('Robustness to invalid or missing place IDs during deserialization', () {
      final rawJson = '{"daysCount": 2, "days": {"1": ["valid_id", "invalid_id_xyz"], "2": []}}';
      prefs.setString('my_trip_data_v1', rawJson);

      final newNotifier = TripNotifier(prefs);
      final state = newNotifier.state;

      expect(state.daysCount, equals(2));
      expect(state.dayPlaces[1], containsAll(['valid_id', 'invalid_id_xyz']));
    });
  });
}
