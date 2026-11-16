import 'package:flutter/foundation.dart';

import '../data/models.dart';
import '../data/remote/catalog_repository.dart';

/// The browsable catalogue, held once for the whole app.
///
/// Starts on the catalogue bundled with the app so the first frame is never
/// empty, then swaps in the Supabase rows when they arrive. Every screen
/// reads through this object rather than the `k...` lists directly, which is
/// what makes the dashboard the source of truth.
class CatalogState extends ChangeNotifier {
  CatalogState({this.repository = const CatalogRepository()});

  final CatalogRepository repository;

  CatalogData _data = CatalogData.bundled();
  bool _loading = false;
  bool _loadedOnce = false;

  List<Restaurant> get restaurants => _data.restaurants;
  List<Hotel> get hotels => _data.hotels;
  List<Property> get properties => _data.properties;
  List<ServicePro> get providers => _data.providers;
  List<Offer> get offers => _data.offers;
  List<Coupon> get coupons => _data.coupons;

  /// True while a fetch is in flight.
  bool get isLoading => _loading;

  /// True once the lists came from Supabase. False means the screens are
  /// showing bundled content — useful for a "demo data" badge.
  bool get isLive => _data.fromRemote;

  Restaurant? restaurantById(String id) => _first(restaurants, id, (r) => r.id);

  Hotel? hotelById(String id) => _first(hotels, id, (h) => h.id);

  Property? propertyById(String id) => _first(properties, id, (p) => p.id);

  ServicePro? providerById(String id) => _first(providers, id, (p) => p.id);

  static T? _first<T>(List<T> items, String id, String Function(T) idOf) {
    for (final item in items) {
      if (idOf(item) == id) return item;
    }
    return null;
  }

  /// Loads the catalogue. Repeat calls are ignored unless [force] is set, so
  /// screens can call this freely in `initState`.
  Future<void> load({bool force = false}) async {
    if (_loading) return;
    if (_loadedOnce && !force) return;
    _loading = true;
    notifyListeners();
    try {
      _data = await repository.fetch();
      _loadedOnce = true;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => load(force: true);
}
