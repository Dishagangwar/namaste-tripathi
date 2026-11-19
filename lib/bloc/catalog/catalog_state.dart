part of 'catalog_bloc.dart';

enum CatalogStatus { initial, loading, ready }

/// The browsable catalogue.
///
/// Never empty: it starts on the catalogue bundled with the app so the first
/// frame has something to paint, then swaps in the Supabase rows. [isLive]
/// says which of the two is on screen.
final class CatalogState extends Equatable {
  CatalogState.bundled()
      : this._fromData(CatalogData.bundled(), CatalogStatus.initial);

  const CatalogState({
    required this.status,
    required this.restaurants,
    required this.hotels,
    required this.properties,
    required this.providers,
    required this.offers,
    required this.coupons,
    required this.isLive,
  });

  CatalogState._fromData(CatalogData data, this.status)
      : restaurants = data.restaurants,
        hotels = data.hotels,
        properties = data.properties,
        providers = data.providers,
        offers = data.offers,
        coupons = data.coupons,
        isLive = data.fromRemote;

  final CatalogStatus status;
  final List<Restaurant> restaurants;
  final List<Hotel> hotels;
  final List<Property> properties;
  final List<ServicePro> providers;
  final List<Offer> offers;
  final List<Coupon> coupons;

  /// True once these lists came from Supabase rather than the bundled data.
  final bool isLive;

  bool get isLoading => status == CatalogStatus.loading;

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

  CatalogState copyWith({CatalogStatus? status}) => CatalogState(
        status: status ?? this.status,
        restaurants: restaurants,
        hotels: hotels,
        properties: properties,
        providers: providers,
        offers: offers,
        coupons: coupons,
        isLive: isLive,
      );

  @override
  List<Object?> get props => [
        status,
        restaurants,
        hotels,
        properties,
        providers,
        offers,
        coupons,
        isLive,
      ];
}
