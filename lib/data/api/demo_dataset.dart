import 'package:flutter/material.dart';

import '../icon_registry.dart';
import '../mock_data.dart';
import '../models.dart';
import '../remote/mappers.dart' show orderStatusToWire;

/// The payloads the demo backend serves.
///
/// Built by serialising the bundled catalogue rather than by hand-writing a
/// second copy of it, so the demo backend can never drift from the app's own
/// data. Keys deliberately match the Supabase column names, which lets both
/// backends share one set of parsers in `remote/mappers.dart`.
class DemoDataset {
  const DemoDataset._();

  static String _hex(Color c) =>
      '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';

  /// IconData cannot be serialised, so it is mapped back to the registry
  /// name the wire format uses.
  static String _iconName(IconData icon) {
    for (final entry in kIconRegistry.entries) {
      if (entry.value == icon) return entry.key;
    }
    return 'settings';
  }

  static Map<String, dynamic> menuItem(MenuItem m) => {
        'id': m.id,
        'name': m.name,
        'description': m.description,
        'price': m.price,
        'image': m.image,
        'category': m.category,
        'is_veg': m.isVeg,
      };

  static Map<String, dynamic> restaurant(Restaurant r) => {
        'id': r.id,
        'name': r.name,
        'cuisine': r.cuisine,
        'rating': r.rating,
        'delivery_time': r.deliveryTime,
        'cost_for_two': r.costForTwo,
        'image': r.image,
        'tags': r.tags,
        'free_delivery': r.freeDelivery,
        'badge': r.badge,
        // Nested rather than a second request: this is a REST API, not a
        // set of database tables.
        'menu': r.menu.map(menuItem).toList(),
      };

  static Map<String, dynamic> hotel(Hotel h) => {
        'id': h.id,
        'name': h.name,
        'category': h.category,
        'rating': h.rating,
        'reviews': h.reviews,
        'location': h.location,
        'distance': h.distance,
        'price_per_night': h.pricePerNight,
        'image': h.image,
        'gallery': h.gallery,
        'amenities': h.amenities,
        'tagline': h.tagline,
        'description': h.description,
        'discount_percent': h.discountPercent,
      };

  static Map<String, dynamic> property(Property p) => {
        'id': p.id,
        'name': p.name,
        'location': p.location,
        'price': p.price,
        'beds': p.beds,
        'baths': p.baths,
        'area': p.area,
        'image': p.image,
        'gallery': p.gallery,
        'tags': p.tags,
        'description': p.description,
        'for_rent': p.forRent,
        'monthly_rent': p.monthlyRent,
        'configuration': p.configuration,
      };

  static Map<String, dynamic> provider(ServicePro p) => {
        'id': p.id,
        'name': p.name,
        'profession': p.profession,
        'category': p.category,
        'profession_color': _hex(p.professionColor),
        'rating': p.rating,
        'reviews': p.reviews,
        'years': p.years,
        'distance': p.distance,
        'photo': p.photo,
        'about': p.about,
        'email': p.email,
        'phone': p.phone,
        'office': p.office,
        'operating_area': p.operatingArea,
        'expertise': [
          for (final e in p.expertise)
            {'label': e.label, 'icon': _iconName(e.icon)},
        ],
        'reviews_list': [
          for (final r in p.testimonials)
            {
              'author': r.name,
              'when_label': r.when,
              'rating': r.rating,
              'body': r.body,
            },
        ],
      };

  static Map<String, dynamic> offer(Offer o) => {
        'code': o.code,
        'title': o.title,
        'subtitle': o.subtitle,
        'image': o.image,
        'color_start': _hex(o.colors.first),
        'color_end': _hex(o.colors.last),
        'valid_till': o.validTill,
      };

  static Map<String, dynamic> coupon(Coupon c) => {
        'code': c.code,
        'description': c.description,
        'flat': c.flat,
        'percent': c.percent,
        'min_order': c.minOrder,
      };

  static Map<String, dynamic> booking(Booking b) => {
        'id': b.id,
        'title': b.title,
        'subtitle': b.subtitle,
        'kind': b.kind,
        'when_label': b.when,
        'status': b.status.name,
        'image': b.image,
        'location': b.location,
        'reference': b.reference,
      };

  static Map<String, dynamic> category(
    ServiceCategory c, {
    bool isWide = false,
  }) =>
      {
        'id': c.id,
        'label': c.label,
        'icon': _iconName(c.icon),
        'is_wide': isWide,
      };

  static Map<String, dynamic> savedPlace(SavedPlace p) => {
        'id': p.id,
        'icon': _iconName(p.icon),
        'label': p.label,
        'address': p.address,
      };

  static Map<String, dynamic> rideOption(RideOption r) => {
        'id': r.id,
        'title': r.title,
        'subtitle': r.subtitle,
        'icon': _iconName(r.icon),
        'color': _hex(r.color),
        'eta': r.eta,
        'price_per_km': r.pricePerKm,
      };

  static Map<String, dynamic> orderLine(OrderLine l) => {
        'item_id': l.itemId,
        'name': l.name,
        'quantity': l.quantity,
        'price': l.price,
      };

  static Map<String, dynamic> order(FoodOrder o) => {
        'id': o.id,
        'restaurant_id': o.restaurantId,
        'restaurant_name': o.restaurantName,
        'image': o.image,
        'lines': o.lines.map(orderLine).toList(),
        'subtotal': o.subtotal,
        'delivery_fee': o.deliveryFee,
        'taxes': o.taxes,
        'discount': o.discount,
        'total': o.total,
        'payment_method': o.paymentMethod,
        'coupon_code': o.couponCode,
        'instructions': o.instructions,
        'status': orderStatusToWire(o.status),
        'reference': o.reference,
        'created_at': o.placedAt?.toIso8601String(),
      };

  static Map<String, dynamic> ride(Ride r) => {
        'id': r.id,
        'option_id': r.optionId,
        'ride_type': r.rideType,
        'from_address': r.fromAddress,
        'to_address': r.toAddress,
        'distance_km': r.distanceKm,
        'fare': r.fare,
        'eta': r.eta,
        'status': r.status.name,
        'reference': r.reference,
      };

  static List<Map<String, dynamic>> get restaurants =>
      kRestaurants.map(restaurant).toList();
  static List<Map<String, dynamic>> get hotels => kHotels.map(hotel).toList();
  static List<Map<String, dynamic>> get properties =>
      kProperties.map(property).toList();
  static List<Map<String, dynamic>> get providers =>
      kProviders.map(provider).toList();
  static List<Map<String, dynamic>> get offers => kOffers.map(offer).toList();
  static List<Map<String, dynamic>> get coupons => kCoupons.map(coupon).toList();
  static List<Map<String, dynamic>> get bookings =>
      kBookings.map(booking).toList();

  /// The whole `/config` payload. The wide service tile rides in the same
  /// list as the grid ones, flagged -- one table, one array, as a real
  /// backend would serve it.
  static Map<String, dynamic> get config => {
        'categories': [
          for (final c in kCategories) category(c),
          category(kWideCategory, isWide: true),
        ],
        'saved_places': kSavedPlaces.map(savedPlace).toList(),
        'ride_options': kRideOptions.map(rideOption).toList(),
        'filters': {
          FilterGroup.cuisine: kCuisineFilters,
          FilterGroup.hotel: kHotelFilters,
          FilterGroup.property: kPropertyFilters,
          FilterGroup.provider: kProviderFilters,
        },
        'traveler_tip': kTravelerTip,
      };

  /// A little order history, so the list is not empty on a fresh install.
  static List<Map<String, dynamic>> get orders => [
        order(FoodOrder(
          id: 'od1',
          restaurantId: 'r1',
          restaurantName: kRestaurants.first.name,
          image: kRestaurants.first.image,
          lines: const [
            OrderLine(
                itemId: 'm1', name: 'Paneer Butter Masala', quantity: 1, price: 320),
            OrderLine(itemId: 'm2', name: 'Garlic Naan', quantity: 2, price: 60),
          ],
          subtotal: 440,
          deliveryFee: 50,
          taxes: 40,
          discount: 0,
          total: 530,
          paymentMethod: 'gpay',
          status: OrderStatus.delivered,
          reference: '#NT-884120',
          placedAt: DateTime(2026, 11, 14, 20, 35),
        )),
      ];

  static List<Map<String, dynamic>> get rides => [
        ride(const Ride(
          id: 'rd1',
          optionId: 'bike',
          rideType: 'Bike taxi',
          fromAddress: 'Diya Green City, Rajnagar Extension',
          toAddress: 'Sector 62, Noida \u2022 Block B',
          distanceKm: 7.4,
          fare: 74,
          eta: '3 min away',
          status: RideStatus.completed,
          reference: '#RD-552018',
        )),
      ];
}
