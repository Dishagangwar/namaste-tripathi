import 'package:flutter/material.dart';

import '../icon_registry.dart';
import '../mock_data.dart';
import '../models.dart';

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
}
