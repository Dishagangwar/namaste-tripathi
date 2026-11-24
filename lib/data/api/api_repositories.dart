import 'package:flutter/foundation.dart';

import '../models.dart';
import '../remote/mappers.dart';
import '../repositories.dart';
import 'api_client.dart';

/// Repositories that talk HTTP through the generated Retrofit client.
///
/// They hold an [ApiClient] but only ever use its `service`: no paths, verbs
/// or response shaping appear here, because those are declared once in
/// `api_service.dart`. What is left is this layer's actual job -- deciding
/// what a failure means to the caller.
///
/// Every method swallows its exception and answers with null or a message,
/// so one unreachable endpoint cannot take down a screen.

class ApiCatalogRepository implements CatalogSource {
  ApiCatalogRepository(this.client);

  final ApiClient client;

  @override
  Future<CatalogData> fetch() async {
    try {
      final api = client.service;

      // Started together, awaited separately: Future.wait over mixed types
      // would erase them back to Object and undo the point of the typed
      // client.
      final restaurants = api.restaurants();
      final hotels = api.hotels();
      final properties = api.properties();
      final providers = api.providers();
      final offers = api.offers();
      final coupons = api.coupons();
      await Future.wait<void>([
        restaurants,
        hotels,
        properties,
        providers,
        offers,
        coupons,
      ]);

      final bundled = CatalogData.bundled();
      List<T> or<T>(List<T> fetched, List<T> fallback) =>
          fetched.isEmpty ? fallback : fetched;

      return CatalogData(
        restaurants: or(
          [for (final w in await restaurants) w.value],
          bundled.restaurants,
        ),
        hotels: or([for (final w in await hotels) w.value], bundled.hotels),
        properties: or(
          [for (final w in await properties) w.value],
          bundled.properties,
        ),
        providers: or(
          [for (final w in await providers) w.value],
          bundled.providers,
        ),
        offers: or([for (final w in await offers) w.value], bundled.offers),
        coupons: or([for (final w in await coupons) w.value], bundled.coupons),
        fromRemote: true,
      );
    } catch (error) {
      debugPrint('API: catalogue fetch failed — ${ApiClient.describeError(error)}');
      return CatalogData.bundled();
    }
  }
}

class ApiConfigRepository implements ConfigSource {
  ApiConfigRepository(this.client);

  final ApiClient client;

  @override
  Future<AppConfig?> fetch() async {
    try {
      // The fallback to the bundled taxonomy happens inside the wire type's
      // fromJson, so a partial payload fills in field by field.
      return (await client.service.config()).value;
    } catch (error) {
      debugPrint('API: config fetch failed — ${ApiClient.describeError(error)}');
      return null;
    }
  }
}

class ApiBookingsRepository implements BookingsSource {
  ApiBookingsRepository(this.client);

  final ApiClient client;

  @override
  Future<List<Booking>?> fetch() async {
    try {
      return [for (final w in await client.service.bookings()) w.value];
    } catch (error) {
      debugPrint('API: bookings fetch failed — ${ApiClient.describeError(error)}');
      return null;
    }
  }

  @override
  Future<Booking?> add(Booking booking) async {
    try {
      return (await client.service.addBooking(bookingToRow(booking))).value;
    } catch (error) {
      debugPrint('API: booking insert failed — ${ApiClient.describeError(error)}');
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
      return [for (final w in await client.service.orders()) w.value];
    } catch (error) {
      debugPrint('API: orders fetch failed — ${ApiClient.describeError(error)}');
      return null;
    }
  }

  @override
  Future<FoodOrder?> place(FoodOrder order) async {
    try {
      return (await client.service.placeOrder(orderToRow(order))).value;
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
      return [for (final w in await client.service.rides()) w.value];
    } catch (error) {
      debugPrint('API: rides fetch failed — ${ApiClient.describeError(error)}');
      return null;
    }
  }

  @override
  Future<Ride?> book(Ride ride) async {
    try {
      return (await client.service.bookRide(rideToRow(ride))).value;
    } catch (error) {
      debugPrint('API: ride booking failed — ${ApiClient.describeError(error)}');
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
      return (await client.service.favourites()).value;
    } catch (error) {
      debugPrint('API: favourites fetch failed — ${ApiClient.describeError(error)}');
      return null;
    }
  }

  @override
  Future<void> add(String itemType, String itemId) async {
    try {
      await client.service
          .addFavourite({'item_type': itemType, 'item_id': itemId});
    } catch (error) {
      debugPrint('API: favourite add failed — ${ApiClient.describeError(error)}');
    }
  }

  @override
  Future<void> remove(String itemType, String itemId) async {
    try {
      await client.service
          .removeFavourite({'item_type': itemType, 'item_id': itemId});
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

  /// Fakes what the real flow does, without Google: demo mode is the backend
  /// a keyless build falls back to, and it has no client IDs to sign in with.
  @override
  Future<SignInResult> signInWithGoogle() async {
    try {
      await client.service.signInWithGoogle();
      _signedIn = true;
      // Flagged as a demo session: no Google account was involved, and the
      // UI has to be able to say so rather than show a normal sign-in.
      return SignInResult.demoSignedIn;
    } catch (error) {
      return SignInResult.failed(ApiClient.describeError(error));
    }
  }

  /// Returns null on success, or a message to show.
  @override
  Future<String?> sendOtp({
    required String countryCode,
    required String phone,
  }) async {
    try {
      await client.service.sendOtp({'phone': formatPhone(countryCode, phone)});
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
      await client.service.verifyOtp({
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
      return (await client.service.profile()).value;
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
      await client.service.saveProfile({
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
      await client.service.signOut();
    } catch (_) {
      // Signing out locally matters more than telling the server.
    }
    _signedIn = false;
  }
}
