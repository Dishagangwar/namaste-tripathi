import 'package:flutter_test/flutter_test.dart';
import 'package:namaste_tripathi/data/api/wire.dart';
import 'package:namaste_tripathi/data/models.dart';

/// The types Retrofit deserialises into.
///
/// Each is a shell around a mapper the Supabase repositories also use, so
/// these tests are really checking that the shared parsers are still reached
/// through the generated client -- and that the nesting which moved out of
/// the repositories came with them.
void main() {
  group('wire types', () {
    test('a nested menu is parsed onto its restaurant', () {
      final wire = RestaurantWire.fromJson({
        'id': 'r1',
        'name': 'The Obsidian Grill',
        'rating': 4.9,
        'tags': ['All'],
        'menu': [
          {'id': 'm1', 'name': 'Truffle Pasta', 'price': 225},
        ],
      });

      expect(wire.value.name, 'The Obsidian Grill');
      expect(wire.value.menu.single.price, 225);
    });

    test('a row missing most of its columns still parses', () {
      // A column added in the dashboard must never white-screen a list.
      final wire = HotelWire.fromJson({'id': 'h1'});
      expect(wire.value.id, 'h1');
      expect(wire.value.rating, 0);
      expect(wire.value.gallery, isEmpty);
    });

    test('a partial config payload fills in from the bundled taxonomy', () {
      final config = AppConfigWire.fromJson({
        'traveler_tip': 'Mind the monsoon.',
        'filters': {
          'cuisine': ['All', 'Thali'],
        },
      }).value;

      expect(config.travelerTip, 'Mind the monsoon.');
      expect(config.filtersFor(FilterGroup.cuisine), ['All', 'Thali']);
      // Untouched by the response, so still bundled.
      expect(config.categories, isNotEmpty);
      expect(config.rideOptions, isNotEmpty);
      expect(config.savedPlaces, isNotEmpty);
    });
  });
}
