import '../mock_data.dart';
import '../models.dart';
import '../remote/mappers.dart';

/// The types Retrofit deserialises into.
///
/// Retrofit needs a `fromJson` on whatever a method returns, and it will not
/// accept `List<dynamic>` or `Map<String, dynamic>` -- the generator emits
/// `dynamic.fromJson(...)` for those, which is not valid Dart.
///
/// Rather than generate a second set of models with json_serializable, each
/// of these is a one-line shell whose `fromJson` calls the mapper the
/// Supabase repositories already use. That keeps the property that matters:
/// one wire format, one set of parsers, two transports. A generated model
/// would have forked the parsing in two and let the backends drift.
///
/// Each holds the domain object in [value]; the repositories unwrap it.

class RestaurantWire {
  const RestaurantWire(this.value);
  final Restaurant value;

  /// The menu arrives nested on its restaurant rather than as a second
  /// request, so it is assembled here instead of in the repository.
  factory RestaurantWire.fromJson(Map<String, dynamic> json) =>
      RestaurantWire(restaurantFromRow(
        json,
        menu: [
          for (final m in (json['menu'] as List? ?? const []))
            if (m is Map) menuItemFromRow(Map<String, dynamic>.from(m)),
        ],
      ));
}

class HotelWire {
  const HotelWire(this.value);
  final Hotel value;

  factory HotelWire.fromJson(Map<String, dynamic> json) =>
      HotelWire(hotelFromRow(json));
}

class PropertyWire {
  const PropertyWire(this.value);
  final Property value;

  factory PropertyWire.fromJson(Map<String, dynamic> json) =>
      PropertyWire(propertyFromRow(json));
}

class ProviderWire {
  const ProviderWire(this.value);
  final ServicePro value;

  factory ProviderWire.fromJson(Map<String, dynamic> json) =>
      ProviderWire(providerFromRow(
        json,
        expertise: [
          for (final e in (json['expertise'] as List? ?? const []))
            if (e is Map) expertiseFromRow(Map<String, dynamic>.from(e)),
        ],
        testimonials: [
          for (final r in (json['reviews_list'] as List? ?? const []))
            if (r is Map) reviewFromRow(Map<String, dynamic>.from(r)),
        ],
      ));
}

class OfferWire {
  const OfferWire(this.value);
  final Offer value;

  factory OfferWire.fromJson(Map<String, dynamic> json) =>
      OfferWire(offerFromRow(json));
}

class CouponWire {
  const CouponWire(this.value);
  final Coupon value;

  factory CouponWire.fromJson(Map<String, dynamic> json) =>
      CouponWire(couponFromRow(json));
}

class BookingWire {
  const BookingWire(this.value);
  final Booking value;

  factory BookingWire.fromJson(Map<String, dynamic> json) =>
      BookingWire(bookingFromRow(json));
}

class OrderWire {
  const OrderWire(this.value);
  final FoodOrder value;

  factory OrderWire.fromJson(Map<String, dynamic> json) =>
      OrderWire(orderFromRow(json));
}

class RideWire {
  const RideWire(this.value);
  final Ride value;

  factory RideWire.fromJson(Map<String, dynamic> json) =>
      RideWire(rideFromRow(json));
}

class AppConfigWire {
  const AppConfigWire(this.value);
  final AppConfig value;

  /// Parsed against the bundled taxonomy, so a partial `/config` payload
  /// fills in field by field rather than blanking a screen.
  factory AppConfigWire.fromJson(Map<String, dynamic> json) =>
      AppConfigWire(appConfigFromRow(json, kBundledConfig));
}

class FavouritesWire {
  const FavouritesWire(this.value);

  /// `{'property': {...ids}, 'restaurant': {...ids}}`.
  final Map<String, Set<String>> value;

  static const propertyType = 'property';
  static const restaurantType = 'restaurant';

  factory FavouritesWire.fromJson(Map<String, dynamic> json) => FavouritesWire({
        propertyType: {
          for (final id in (json[propertyType] as List? ?? const []))
            id.toString(),
        },
        restaurantType: {
          for (final id in (json[restaurantType] as List? ?? const []))
            id.toString(),
        },
      });
}

/// The profile is read as a loose map by [AuthSource], so this carries the
/// row through untouched rather than inventing a model for it.
class ProfileWire {
  const ProfileWire(this.value);
  final Map<String, dynamic> value;

  factory ProfileWire.fromJson(Map<String, dynamic> json) => ProfileWire(json);
}
