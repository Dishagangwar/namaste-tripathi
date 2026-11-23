import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:namaste_tripathi/bloc/catalog/catalog_bloc.dart';
import 'package:namaste_tripathi/data/backend.dart';
import 'package:namaste_tripathi/core/google_auth_config.dart';
import 'package:namaste_tripathi/core/supabase_config.dart';
import 'package:namaste_tripathi/core/theme.dart';
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
      // Asserted against the token, not a literal, so re-theming the app
      // cannot leave this test pinning a colour nothing uses any more.
      expect(colorFromHex('nonsense'), AppColors.primary);
      expect(colorFromHex(null), AppColors.primary);
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

    test('an order row round-trips through the insert payload', () {
      const order = FoodOrder(
        id: 'local',
        restaurantId: 'r1',
        restaurantName: 'The Obsidian Grill',
        image: 'assets/images/restaurant1.jpg',
        lines: [
          OrderLine(itemId: 'm1', name: 'Pasta', quantity: 2, price: 225),
        ],
        subtotal: 450,
        deliveryFee: 50,
        taxes: 41,
        discount: 90,
        total: 451,
        paymentMethod: 'gpay',
        couponCode: 'SAVE20',
        instructions: ['No onion'],
      );

      final row = orderToRow(order);
      // The id and user_id are the database's to fill.
      expect(row.containsKey('id'), isFalse);
      expect(row.containsKey('user_id'), isFalse);

      final parsed = orderFromRow({...row, 'id': 'srv', 'reference': '#NT-1'});
      expect(parsed.id, 'srv');
      expect(parsed.reference, '#NT-1');
      expect(parsed.restaurantName, 'The Obsidian Grill');
      expect(parsed.lines.single.quantity, 2);
      expect(parsed.lines.single.total, 450);
      expect(parsed.couponCode, 'SAVE20');
      expect(parsed.instructions, ['No onion']);
      expect(parsed.total, 451);
    });

    test('on_the_way is mapped explicitly in both directions', () {
      // The enum name is `onTheWay`, so neither direction can be derived
      // from it -- a snake_case assumption would silently fail.
      expect(orderStatusToWire(OrderStatus.onTheWay), 'on_the_way');
      expect(orderFromRow({'status': 'on_the_way'}).status,
          OrderStatus.onTheWay);
      expect(orderFromRow({'status': 'teleporting'}).status,
          OrderStatus.placed);
    });

    test('an order with no lines parses as an empty order, not a crash', () {
      final parsed = orderFromRow({'id': 'o1'});
      expect(parsed.lines, isEmpty);
      expect(parsed.itemCount, 0);
      expect(parsed.total, 0);
    });

    test('a ride row round-trips through the insert payload', () {
      const ride = Ride(
        id: 'local',
        optionId: 'bike',
        rideType: 'Bike taxi',
        fromAddress: 'Home',
        toAddress: 'Sector 62',
        distanceKm: 7.4,
        fare: 74,
        eta: '3 min away',
      );

      final row = rideToRow(ride);
      expect(row.containsKey('id'), isFalse);

      final parsed = rideFromRow({...row, 'id': 'srv', 'reference': '#RD-1'});
      expect(parsed.id, 'srv');
      expect(parsed.optionId, 'bike');
      expect(parsed.distanceKm, 7.4);
      expect(parsed.fare, 74);
      expect(parsed.status, RideStatus.searching);
    });

    test('a ride option row resolves its icon and colour', () {
      final option = rideOptionFromRow({
        'id': 'erickshaw',
        'title': 'E-rickshaw',
        'subtitle': 'Cheaper and Reliable',
        'icon': 'electric_rickshaw',
        'color': '#16A34A',
        'eta': '6 min away',
        'price_per_km': 6,
      });

      expect(option.icon, kIconRegistry['electric_rickshaw']);
      expect(option.color.toARGB32(), 0xFF16A34A);
      // 6 x 10 = 60, plus the flag-down charge.
      expect(option.fareFor(10), 60 + RideOption.baseFare);
    });

    test('the config payload splits the wide tile out of the grid', () {
      final config = appConfigFromRow({
        'categories': [
          {'id': 'food', 'label': 'Food', 'icon': 'restaurant', 'is_wide': false},
          {'id': 'pros', 'label': 'Pros', 'icon': 'handyman', 'is_wide': true},
        ],
        'saved_places': [
          {'id': 'h', 'icon': 'home', 'label': 'Home', 'address': 'A'},
        ],
        'filters': {
          'cuisine': ['All', 'Thali'],
        },
        'traveler_tip': 'Carry water.',
      }, kBundledConfig);

      expect(config.categories.single.id, 'food');
      expect(config.wideCategory.id, 'pros');
      expect(config.savedPlaces.single.label, 'Home');
      expect(config.filtersFor('cuisine'), ['All', 'Thali']);
      expect(config.travelerTip, 'Carry water.');
      // Not served, so the bundled classes stand.
      expect(config.rideOptions, kBundledConfig.rideOptions);
    });

    test('an empty config payload falls back field by field', () {
      final config = appConfigFromRow(const {}, kBundledConfig);

      expect(config.categories, kBundledConfig.categories);
      expect(config.wideCategory, kBundledConfig.wideCategory);
      expect(config.savedPlaces, kBundledConfig.savedPlaces);
      expect(config.rideOptions, kBundledConfig.rideOptions);
      expect(config.travelerTip, kBundledConfig.travelerTip);
      expect(config.filtersFor(FilterGroup.provider),
          kProviderFilters);
    });

    test('an empty filter group is dropped rather than served empty', () {
      // An empty chip row would look broken; the bundled group stands.
      final config = appConfigFromRow({
        'filters': {'cuisine': <String>[]},
      }, kBundledConfig);

      expect(config.filtersFor(FilterGroup.cuisine), kCuisineFilters);
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

  group('backend choice', () {
    tearDown(Backend.reset);

    test('it says why it picked what it picked', () {
      // Without a key compiled in, a test build falls back to demo.
      Backend.reset();
      expect(Backend.isDemo, isTrue);
      // The message has to name the missing define, not just say
      // "unconfigured": that vagueness cost three separate bug hunts.
      expect(Backend.reason, contains('no BACKEND define'));
      expect(Backend.reason, contains('SUPABASE_PUBLISHABLE_KEY'));
    });

    test('a forced mode says it was forced', () {
      Backend.mode = BackendMode.supabase;
      expect(Backend.reason, contains('forced'));
    });
  });

  group('Google client IDs', () {
    test('a real client ID is accepted', () {
      expect(
        GoogleAuthConfig.looksLikeClientId(
          '229993461987-rj1oj8h8envnjpdbhrjpnosnuc7f3dgj'
          '.apps.googleusercontent.com',
        ),
        isTrue,
      );
    });

    test('a placeholder ending in the real suffix is refused', () {
      // This one got through a suffix-only check and reported the build as
      // configured, so sign-in failed inside Google's SDK instead of here.
      expect(
        GoogleAuthConfig.looksLikeClientId(
          'PASTE_YOUR_IOS_CLIENT_ID.apps.googleusercontent.com',
        ),
        isFalse,
      );
    });

    test('a stray character before the project number is refused', () {
      // Left behind by overwriting PASTE_YOUR_WEB_CLIENT_ID: the P stayed.
      expect(
        GoogleAuthConfig.looksLikeClientId(
          'P229993461987-rj1oj8h8envnjpdbhrjpnosnuc7f3dgj'
          '.apps.googleusercontent.com',
        ),
        isFalse,
      );
    });

    test('empty and almost-right values are refused', () {
      expect(GoogleAuthConfig.looksLikeClientId(''), isFalse);
      expect(GoogleAuthConfig.looksLikeClientId('229993461987'), isFalse);
      expect(
        GoogleAuthConfig.looksLikeClientId('229993461987-abc.googleusercontent.com'),
        isFalse,
      );
      // Trailing text after the suffix must not slip past either.
      expect(
        GoogleAuthConfig.looksLikeClientId(
          '229993461987-abc.apps.googleusercontent.com/extra',
        ),
        isFalse,
      );
    });

    test('a build with no client ID is not treated as configured', () {
      // Nothing is compiled in under `flutter test`.
      expect(GoogleAuthConfig.isConfigured, isFalse);
      expect(GoogleAuthConfig.serverClientIdOrNull, isNull);
      expect(GoogleAuthConfig.iosClientIdOrNull, isNull);
    });
  });

  group('catalogue fallback', () {
    // This group is about the Supabase path specifically; without pinning
    // it, a keyless checkout now resolves to the demo backend instead.
    setUp(() => Backend.mode = BackendMode.supabase);
    tearDown(Backend.reset);

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

    test('the bloc opens on bundled data, before any event', () {
      final state = CatalogBloc().state;

      expect(state.status, CatalogStatus.initial);
      expect(state.isLive, isFalse);
      expect(state.restaurants, isNotEmpty);
      expect(state.restaurantById('r1')?.name, 'The Obsidian Grill');
      expect(state.restaurantById('nope'), isNull);
      expect(state.hotelById('h1'), isNotNull);
      expect(state.propertyById('pr7')?.forRent, isTrue);
      expect(state.providerById('sp1')?.category, 'Electricians');
    });

    test('an unreachable project leaves the UI on bundled data', () async {
      // No key is compiled into the test binary, so the repository takes the
      // offline path rather than attempting a request.
      final bloc = CatalogBloc()..add(const CatalogRequested());
      await bloc.stream.firstWhere((s) => s.status == CatalogStatus.ready);

      expect(bloc.state.isLoading, isFalse);
      expect(bloc.state.isLive, isFalse);
      expect(bloc.state.restaurants, isNotEmpty);
      expect(bloc.state.offers, isNotEmpty);
      await bloc.close();
    });

    test('CatalogRequested loads once; CatalogRefreshed always re-fetches',
        () async {
      final bloc = CatalogBloc();
      final seen = <CatalogStatus>[];
      final sub = bloc.stream.listen((s) => seen.add(s.status));

      bloc.add(const CatalogRequested());
      await bloc.stream.firstWhere((s) => s.status == CatalogStatus.ready);

      // The second request is swallowed, so no further loading state.
      bloc.add(const CatalogRequested());
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(seen.where((s) => s == CatalogStatus.loading).length, 1);

      bloc.add(const CatalogRefreshed());
      await bloc.stream.firstWhere((s) => s.status == CatalogStatus.ready);
      expect(seen.where((s) => s == CatalogStatus.loading).length, 2);

      await sub.cancel();
      await bloc.close();
    });
  });
}
