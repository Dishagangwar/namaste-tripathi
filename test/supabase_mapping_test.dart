import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:namaste_tripathi/core/catalog_state.dart';
import 'package:namaste_tripathi/core/supabase_config.dart';
import 'package:namaste_tripathi/data/icon_registry.dart';
import 'package:namaste_tripathi/data/mock_data.dart';
import 'package:namaste_tripathi/data/models.dart';
import 'package:namaste_tripathi/data/remote/catalog_repository.dart';
import 'package:namaste_tripathi/data/remote/mappers.dart';

/// Rows arrive as untyped JSON, so a renamed or missing column would surface
/// as a runtime crash inside a list builder. These tests pin the mapping and
/// the bundled-data fallback that keeps the app usable offline.
void main() {
  group('row mapping', () {
    test('a restaurant row carries its menu across', () {
      final restaurant = restaurantFromRow(
        {
          'id': 'r1',
          'name': 'The Obsidian Grill',
          'cuisine': 'Wood-fired',
          'rating': 4.9,
          'delivery_time': '25-35 min',
          'cost_for_two': 250,
          'image': 'assets/images/restaurant1.jpg',
          'tags': ['Continental', 'All'],
          'free_delivery': true,
          'badge': 'Crowd Favorite',
        },
        menu: [
          menuItemFromRow({
            'id': 'm1',
            'name': 'Truffle Pasta',
            'price': '225.00',
            'category': 'Popular',
            'is_veg': false,
          }),
        ],
      );

      expect(restaurant.name, 'The Obsidian Grill');
      expect(restaurant.rating, 4.9);
      expect(restaurant.tags, ['Continental', 'All']);
      expect(restaurant.badge, 'Crowd Favorite');
      expect(restaurant.menu.single.price, 225);
      expect(restaurant.menu.single.isVeg, isFalse);
    });

    test('missing columns fall back instead of throwing', () {
      final hotel = hotelFromRow({'id': 'h9'});

      expect(hotel.name, '');
      expect(hotel.rating, 0);
      expect(hotel.gallery, isEmpty);
      expect(hotel.amenities, isEmpty);
      expect(hotel.discountPercent, 0);
    });

    test('an empty badge reads as no badge', () {
      expect(restaurantFromRow({'id': 'r9', 'badge': ''}).badge, isNull);
      expect(restaurantFromRow({'id': 'r9'}).badge, isNull);
    });

    test('hex colours parse in both lengths, bad ones fall back', () {
      expect(colorFromHex('#C2185B'), const Color(0xFFC2185B));
      expect(colorFromHex('0E7490'), const Color(0xFF0E7490));
      expect(colorFromHex('#800B4EA2'), const Color(0x800B4EA2));
      expect(colorFromHex('nonsense'), const Color(0xFF0B4EA2));
      expect(colorFromHex(null), const Color(0xFF0B4EA2));
    });

    test('expertise icons resolve by name and degrade safely', () {
      expect(
        expertiseFromRow({'label': 'Wiring', 'icon': 'electrical_services'})
            .icon,
        Icons.electrical_services_rounded,
      );
      expect(
        expertiseFromRow({'label': 'Something new', 'icon': 'not_a_real_icon'})
            .icon,
        iconFromName(null),
      );
    });

    test('a booking round-trips through the insert payload', () {
      const booking = Booking(
        id: 'local-1',
        title: 'Azure Bay Resort',
        subtitle: 'Ocean Suite',
        kind: 'Luxury Stay',
        when: 'Oct 24 - Oct 28',
        status: BookingStatus.processing,
        image: 'assets/images/hotel4.jpg',
        location: 'Amalfi, Italy',
        reference: '#AB-992384',
      );

      final payload = bookingToRow(booking);
      // id and user_id are the database's to assign.
      expect(payload.containsKey('id'), isFalse);
      expect(payload.containsKey('user_id'), isFalse);
      expect(payload['status'], 'processing');

      final restored = bookingFromRow({...payload, 'id': 'uuid-from-db'});
      expect(restored.id, 'uuid-from-db');
      expect(restored.title, booking.title);
      expect(restored.status, BookingStatus.processing);
      expect(restored.location, 'Amalfi, Italy');
    });

    test('an unknown booking status does not crash the list', () {
      expect(
        bookingFromRow({'id': 'b1', 'status': 'cancelled'}).status,
        BookingStatus.confirmed,
      );
    });
  });

  group('config', () {
    test('the project URL is baked in', () {
      expect(SupabaseConfig.url, 'https://cwfozayeingrqomplcgg.supabase.co');
    });

    test('a build with no key is not treated as configured', () {
      // Nothing passes --dart-define to `flutter test`, so this is the
      // offline path every other test relies on.
      expect(SupabaseConfig.key, isEmpty);
      expect(SupabaseConfig.isConfigured, isFalse);
    });
  });

  group('catalogue fallback', () {
    test('the bundled snapshot matches the shipped lists', () {
      final bundled = CatalogData.bundled();

      expect(bundled.fromRemote, isFalse);
      expect(bundled.restaurants, same(kRestaurants));
      expect(bundled.hotels, same(kHotels));
      expect(bundled.properties, same(kProperties));
      expect(bundled.providers, same(kProviders));
      expect(bundled.offers, same(kOffers));
      expect(bundled.coupons, same(kCoupons));
    });

    test('CatalogState serves bundled data before anything loads', () {
      final state = CatalogState();

      expect(state.isLive, isFalse);
      expect(state.restaurants, isNotEmpty);
      expect(state.restaurantById('r1')?.name, 'The Obsidian Grill');
      expect(state.restaurantById('nope'), isNull);
      expect(state.hotelById('h1'), isNotNull);
      expect(state.propertyById('pr7')?.forRent, isTrue);
      expect(state.providerById('sp1')?.category, 'Electricians');
    });

    test('an unreachable project leaves the UI on bundled data', () async {
      // No key is compiled into the test binary, so the repository must take
      // the offline path rather than attempting a request.
      final state = CatalogState();
      await state.load();

      expect(state.isLoading, isFalse);
      expect(state.isLive, isFalse);
      expect(state.restaurants, isNotEmpty);
      expect(state.offers, isNotEmpty);
    });
  });
}
