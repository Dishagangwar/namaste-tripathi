import 'package:flutter/foundation.dart';

import '../mock_data.dart';
import '../models.dart';
import 'mappers.dart';
import 'supabase_service.dart';

/// Everything the browsing screens need, in one immutable snapshot.
@immutable
class CatalogData {
  const CatalogData({
    required this.restaurants,
    required this.hotels,
    required this.properties,
    required this.providers,
    required this.offers,
    required this.coupons,
    required this.fromRemote,
  });

  /// The catalogue bundled with the app, used until Supabase answers and
  /// whenever it cannot be reached.
  CatalogData.bundled()
      : restaurants = kRestaurants,
        hotels = kHotels,
        properties = kProperties,
        providers = kProviders,
        offers = kOffers,
        coupons = kCoupons,
        fromRemote = false;

  final List<Restaurant> restaurants;
  final List<Hotel> hotels;
  final List<Property> properties;
  final List<ServicePro> providers;
  final List<Offer> offers;
  final List<Coupon> coupons;

  /// True when these lists came from Supabase rather than the bundled data.
  final bool fromRemote;
}

/// Reads the public catalogue from Supabase.
///
/// Reads only — the catalogue tables grant `select` to anon and authenticated
/// and nothing else, so content is edited in the dashboard or with a
/// service-role key, never from a phone.
class CatalogRepository {
  const CatalogRepository();

  static const _restaurantColumns =
      'id, name, cuisine, rating, delivery_time, cost_for_two, image, tags, '
      'free_delivery, badge, sort_order';

  /// Fetches the whole catalogue. Returns the bundled catalogue if Supabase
  /// is not configured, is unreachable, or returns nothing usable.
  Future<CatalogData> fetch() async {
    if (!SupabaseService.isReady) return CatalogData.bundled();

    try {
      final client = SupabaseService.client;
      // `order` defaults to DESCENDING in supabase-dart, so `ascending: true`
      // is load-bearing: without it the catalogue renders back to front.
      final results = await Future.wait([
        client
            .from('restaurants')
            .select(_restaurantColumns)
            .order('sort_order', ascending: true),
        client.from('menu_items').select().order('sort_order', ascending: true),
        client.from('hotels').select().order('sort_order', ascending: true),
        client.from('properties').select().order('sort_order', ascending: true),
        client
            .from('service_providers')
            .select()
            .order('sort_order', ascending: true),
        client
            .from('provider_expertise')
            .select()
            .order('sort_order', ascending: true),
        client
            .from('provider_reviews')
            .select()
            .order('sort_order', ascending: true),
        client.from('offers').select().order('sort_order', ascending: true),
        client.from('coupons').select().order('sort_order', ascending: true),
      ]);

      final restaurantRows = _rows(results[0]);
      final menuRows = _rows(results[1]);
      final hotelRows = _rows(results[2]);
      final propertyRows = _rows(results[3]);
      final providerRows = _rows(results[4]);
      final expertiseRows = _rows(results[5]);
      final reviewRows = _rows(results[6]);
      final offerRows = _rows(results[7]);
      final couponRows = _rows(results[8]);

      // An empty catalogue almost always means the seed has not been run
      // yet; showing the bundled data beats showing empty screens.
      if (restaurantRows.isEmpty && hotelRows.isEmpty && propertyRows.isEmpty) {
        debugPrint('Supabase: catalogue is empty — run supabase/seed.sql.');
        return CatalogData.bundled();
      }

      final menuByRestaurant = <String, List<MenuItem>>{};
      for (final row in menuRows) {
        final parent = str(row, 'restaurant_id');
        if (parent.isEmpty) continue;
        menuByRestaurant
            .putIfAbsent(parent, () => <MenuItem>[])
            .add(menuItemFromRow(row));
      }

      final expertiseByProvider = <String, List<Expertise>>{};
      for (final row in expertiseRows) {
        final parent = str(row, 'provider_id');
        if (parent.isEmpty) continue;
        expertiseByProvider
            .putIfAbsent(parent, () => <Expertise>[])
            .add(expertiseFromRow(row));
      }

      final reviewsByProvider = <String, List<Review>>{};
      for (final row in reviewRows) {
        final parent = str(row, 'provider_id');
        if (parent.isEmpty) continue;
        reviewsByProvider
            .putIfAbsent(parent, () => <Review>[])
            .add(reviewFromRow(row));
      }

      final restaurants = [
        for (final row in restaurantRows)
          restaurantFromRow(
            row,
            menu: menuByRestaurant[str(row, 'id')] ?? const [],
          ),
      ];

      final providers = [
        for (final row in providerRows)
          providerFromRow(
            row,
            expertise: expertiseByProvider[str(row, 'id')] ?? const [],
            testimonials: reviewsByProvider[str(row, 'id')] ?? const [],
          ),
      ];

      final bundled = CatalogData.bundled();
      return CatalogData(
        restaurants: restaurants.isEmpty ? bundled.restaurants : restaurants,
        hotels: hotelRows.isEmpty
            ? bundled.hotels
            : [for (final row in hotelRows) hotelFromRow(row)],
        properties: propertyRows.isEmpty
            ? bundled.properties
            : [for (final row in propertyRows) propertyFromRow(row)],
        providers: providers.isEmpty ? bundled.providers : providers,
        offers: offerRows.isEmpty
            ? bundled.offers
            : [for (final row in offerRows) offerFromRow(row)],
        coupons: couponRows.isEmpty
            ? bundled.coupons
            : [for (final row in couponRows) couponFromRow(row)],
        fromRemote: true,
      );
    } catch (error, stack) {
      debugPrint('Supabase: catalogue fetch failed — $error');
      debugPrintStack(stackTrace: stack);
      return CatalogData.bundled();
    }
  }

  List<Map<String, dynamic>> _rows(dynamic result) {
    if (result is! List) return const [];
    return [
      for (final row in result)
        if (row is Map) Map<String, dynamic>.from(row),
    ];
  }
}
