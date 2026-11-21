import 'package:flutter/foundation.dart';

import '../mock_data.dart';
import '../models.dart';
import '../repositories.dart';
import '../remote/mappers.dart';
import 'api_client.dart';

/// Repositories that talk HTTP through [ApiClient].
///
/// They parse with the same `mappers.dart` the Supabase repositories use,
/// because the demo backend serves the same field names. One wire format,
/// one set of parsers, two transports.

class ApiCatalogRepository implements CatalogSource {
  ApiCatalogRepository(this.client);

  final ApiClient client;

  @override
  Future<CatalogData> fetch() async {
    try {
      final results = await Future.wait([
        client.getList('/catalog/restaurants'),
        client.getList('/catalog/hotels'),
        client.getList('/catalog/properties'),
        client.getList('/catalog/providers'),
        client.getList('/catalog/offers'),
        client.getList('/catalog/coupons'),
      ]);

      final bundled = CatalogData.bundled();
      final restaurants = [
        for (final row in results[0])
          restaurantFromRow(
            row,
            // Nested by this API rather than fetched separately.
            menu: [
              for (final m in (row['menu'] as List? ?? const []))
                if (m is Map) menuItemFromRow(Map<String, dynamic>.from(m)),
            ],
          ),
      ];

      final providers = [
        for (final row in results[3])
          providerFromRow(
            row,
            expertise: [
              for (final e in (row['expertise'] as List? ?? const []))
                if (e is Map) expertiseFromRow(Map<String, dynamic>.from(e)),
            ],
            testimonials: [
              for (final r in (row['reviews_list'] as List? ?? const []))
                if (r is Map) reviewFromRow(Map<String, dynamic>.from(r)),
            ],
          ),
      ];

      return CatalogData(
        restaurants: restaurants.isEmpty ? bundled.restaurants : restaurants,
        hotels: results[1].isEmpty
            ? bundled.hotels
            : [for (final r in results[1]) hotelFromRow(r)],
        properties: results[2].isEmpty
            ? bundled.properties
            : [for (final r in results[2]) propertyFromRow(r)],
        providers: providers.isEmpty ? bundled.providers : providers,
        offers: results[4].isEmpty
            ? bundled.offers
            : [for (final r in results[4]) offerFromRow(r)],
        coupons: results[5].isEmpty
            ? bundled.coupons
            : [for (final r in results[5]) couponFromRow(r)],
        fromRemote: true,
      );
    } catch (error) {
      debugPrint('API: catalogue fetch failed — ${ApiClient.describeError(error)}');
      return CatalogData.bundled();
    }
  }
}

class ApiBookingsRepository implements BookingsSource {
  ApiBookingsRepository(this.client);

  final ApiClient client;

  @override
  Future<List<Booking>?> fetch() async {
    try {
      final rows = await client.getList('/bookings');
      return [for (final row in rows) bookingFromRow(row)];
    } catch (error) {
      debugPrint('API: bookings fetch failed — ${ApiClient.describeError(error)}');
      return null;
    }
  }

  @override
  Future<Booking?> add(Booking booking) async {
    try {
      final row = await client.post('/bookings', body: bookingToRow(booking));
      return row == null ? null : bookingFromRow(row);
    } catch (error) {
      debugPrint('API: booking insert failed — ${ApiClient.describeError(error)}');
      return null;
    }
  }
}

class ApiFavouritesRepository implements FavouritesSource {
  ApiFavouritesRepository(this.client);

  static const propertyType = 'property';
  static const restaurantType = 'restaurant';

  final ApiClient client;

  @override
  Future<Map<String, Set<String>>?> fetch() async {
    try {
      final row = await client.getObject('/favourites');
      if (row == null) return null;
      return {
        propertyType: {
          for (final id in (row[propertyType] as List? ?? const []))
            id.toString(),
        },
        restaurantType: {
          for (final id in (row[restaurantType] as List? ?? const []))
            id.toString(),
        },
      };
    } catch (error) {
      debugPrint('API: favourites fetch failed — ${ApiClient.describeError(error)}');
      return null;
    }
  }

  @override
  Future<void> add(String itemType, String itemId) async {
    try {
      await client.post('/favourites',
          body: {'item_type': itemType, 'item_id': itemId});
    } catch (error) {
      debugPrint('API: favourite add failed — ${ApiClient.describeError(error)}');
    }
  }

  @override
  Future<void> remove(String itemType, String itemId) async {
    try {
      await client.delete('/favourites',
          body: {'item_type': itemType, 'item_id': itemId});
    } catch (error) {
      debugPrint('API: favourite remove failed — ${ApiClient.describeError(error)}');
    }
  }
}

class ApiAuthRepository implements AuthSource {
  ApiAuthRepository(this.client);

  final ApiClient client;

  bool _signedIn = false;
  @override
  bool get isSignedIn => _signedIn;

  @override
  String formatPhone(String countryCode, String number) {
    final digits = number.replaceAll(RegExp(r'\D'), '');
    final code = countryCode.replaceAll(RegExp(r'[^\d+]'), '');
    return code.startsWith('+') ? '$code$digits' : '+$code$digits';
  }

  /// Returns null on success, or a message to show.
  @override
  Future<String?> sendOtp({
    required String countryCode,
    required String phone,
  }) async {
    try {
      await client.post('/auth/otp',
          body: {'phone': formatPhone(countryCode, phone)});
      return null;
    } catch (error) {
      return ApiClient.describeError(error);
    }
  }

  @override
  Future<String?> verifyOtp({
    required String countryCode,
    required String phone,
    required String token,
  }) async {
    try {
      await client.post('/auth/verify', body: {
        'phone': formatPhone(countryCode, phone),
        'token': token,
      });
      _signedIn = true;
      return null;
    } catch (error) {
      return ApiClient.describeError(error);
    }
  }

  @override
  Future<Map<String, dynamic>?> fetchProfile() async {
    try {
      return await client.getObject('/profile');
    } catch (error) {
      debugPrint('API: profile fetch failed — ${ApiClient.describeError(error)}');
      return null;
    }
  }

  @override
  Future<void> saveProfile({
    String? fullName,
    String? role,
    String? locationLabel,
    String? address,
  }) async {
    try {
      await client.patch('/profile', body: {
        'full_name': ?fullName,
        'role': ?role,
        'location_label': ?locationLabel,
        'address': ?address,
      });
    } catch (error) {
      debugPrint('API: profile save failed — ${ApiClient.describeError(error)}');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await client.post('/auth/signout');
    } catch (_) {
      // Signing out locally matters more than telling the server.
    }
    _signedIn = false;
  }
}

class ApiConfigRepository implements ConfigSource {
  ApiConfigRepository(this.client);

  final ApiClient client;

  @override
  Future<AppConfig?> fetch() async {
    try {
      final row = await client.getObject('/config');
      if (row == null) return null;
      // Parsed against the bundled taxonomy, so a partial payload fills in
      // field by field rather than blanking a screen.
      return appConfigFromRow(row, kBundledConfig);
    } catch (error) {
      debugPrint('API: config fetch failed — ${ApiClient.describeError(error)}');
      return null;
    }
  }
}

class ApiOrdersRepository implements OrdersSource {
  ApiOrdersRepository(this.client);

  final ApiClient client;

  @override
  Future<List<FoodOrder>?> fetch() async {
    try {
      final rows = await client.getList('/orders');
      return [for (final row in rows) orderFromRow(row)];
    } catch (error) {
      debugPrint('API: orders fetch failed — ${ApiClient.describeError(error)}');
      return null;
    }
  }

  @override
  Future<FoodOrder?> place(FoodOrder order) async {
    try {
      final row = await client.post('/orders', body: orderToRow(order));
      return row == null ? null : orderFromRow(row);
    } catch (error) {
      debugPrint('API: order failed — ${ApiClient.describeError(error)}');
      return null;
    }
  }
}

class ApiRidesRepository implements RidesSource {
  ApiRidesRepository(this.client);

  final ApiClient client;

  @override
  Future<List<Ride>?> fetch() async {
    try {
      final rows = await client.getList('/rides');
      return [for (final row in rows) rideFromRow(row)];
    } catch (error) {
      debugPrint('API: rides fetch failed — ${ApiClient.describeError(error)}');
      return null;
    }
  }

  @override
  Future<Ride?> book(Ride ride) async {
    try {
      final row = await client.post('/rides', body: rideToRow(ride));
      return row == null ? null : rideFromRow(row);
    } catch (error) {
      debugPrint('API: ride booking failed — ${ApiClient.describeError(error)}');
      return null;
    }
  }
}
