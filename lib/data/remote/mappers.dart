import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../icon_registry.dart';
import '../models.dart';

/// Row -> model translation for every Supabase table.
///
/// Every reader is defensive: a missing or null column yields a sensible
/// default instead of a `TypeError` deep inside a list builder, so adding a
/// column in the dashboard can never white-screen the app.

String str(Map<String, dynamic> row, String key, [String fallback = '']) {
  final value = row[key];
  if (value == null) return fallback;
  return value.toString();
}

String? strOrNull(Map<String, dynamic> row, String key) {
  final value = row[key];
  if (value == null) return null;
  final text = value.toString();
  return text.isEmpty ? null : text;
}

double dbl(Map<String, dynamic> row, String key, [double fallback = 0]) {
  final value = row[key];
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? fallback;
  return fallback;
}

int integer(Map<String, dynamic> row, String key, [int fallback = 0]) {
  final value = row[key];
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}

bool boolean(Map<String, dynamic> row, String key, [bool fallback = false]) {
  final value = row[key];
  if (value is bool) return value;
  if (value is String) return value.toLowerCase() == 'true';
  return fallback;
}

List<String> strList(Map<String, dynamic> row, String key) {
  final value = row[key];
  if (value is List) {
    return value.where((e) => e != null).map((e) => e.toString()).toList();
  }
  return const [];
}

/// Parses `#RRGGBB` / `#AARRGGBB` / `RRGGBB`. Falls back to the brand
/// colour, taken from the theme so a repaint cannot leave a stale literal
/// behind in the data layer.
Color colorFromHex(String? hex, [Color fallback = AppColors.primary]) {
  if (hex == null) return fallback;
  var value = hex.trim().replaceFirst('#', '');
  if (value.length == 6) value = 'FF$value';
  if (value.length != 8) return fallback;
  final parsed = int.tryParse(value, radix: 16);
  return parsed == null ? fallback : Color(parsed);
}

// ---------------------------------------------------------------- food

MenuItem menuItemFromRow(Map<String, dynamic> row) => MenuItem(
      id: str(row, 'id'),
      name: str(row, 'name'),
      description: str(row, 'description'),
      price: dbl(row, 'price'),
      image: str(row, 'image'),
      category: str(row, 'category', 'Popular'),
      isVeg: boolean(row, 'is_veg', true),
    );

Restaurant restaurantFromRow(
  Map<String, dynamic> row, {
  List<MenuItem> menu = const [],
}) =>
    Restaurant(
      id: str(row, 'id'),
      name: str(row, 'name'),
      cuisine: str(row, 'cuisine'),
      rating: dbl(row, 'rating'),
      deliveryTime: str(row, 'delivery_time'),
      costForTwo: integer(row, 'cost_for_two'),
      image: str(row, 'image'),
      tags: strList(row, 'tags'),
      freeDelivery: boolean(row, 'free_delivery', true),
      badge: strOrNull(row, 'badge'),
      menu: menu,
    );

Coupon couponFromRow(Map<String, dynamic> row) => Coupon(
      str(row, 'code'),
      str(row, 'description'),
      dbl(row, 'flat'),
      dbl(row, 'percent'),
      dbl(row, 'min_order'),
    );

// ---------------------------------------------------------------- hotels

Hotel hotelFromRow(Map<String, dynamic> row) => Hotel(
      id: str(row, 'id'),
      name: str(row, 'name'),
      category: str(row, 'category', 'Luxury'),
      rating: dbl(row, 'rating'),
      reviews: integer(row, 'reviews'),
      location: str(row, 'location'),
      distance: str(row, 'distance'),
      pricePerNight: integer(row, 'price_per_night'),
      image: str(row, 'image'),
      gallery: strList(row, 'gallery'),
      amenities: strList(row, 'amenities'),
      tagline: str(row, 'tagline'),
      description: str(row, 'description'),
      discountPercent: integer(row, 'discount_percent'),
    );

// ---------------------------------------------------------------- real estate

Property propertyFromRow(Map<String, dynamic> row) => Property(
      id: str(row, 'id'),
      name: str(row, 'name'),
      location: str(row, 'location'),
      price: integer(row, 'price'),
      beds: integer(row, 'beds'),
      baths: integer(row, 'baths'),
      area: integer(row, 'area'),
      image: str(row, 'image'),
      gallery: strList(row, 'gallery'),
      tags: strList(row, 'tags'),
      description: str(row, 'description'),
      forRent: boolean(row, 'for_rent'),
      monthlyRent: integer(row, 'monthly_rent'),
      configuration: str(row, 'configuration'),
    );

// ---------------------------------------------------------------- providers

Expertise expertiseFromRow(Map<String, dynamic> row) => Expertise(
      str(row, 'label'),
      iconFromName(strOrNull(row, 'icon')),
    );

Review reviewFromRow(Map<String, dynamic> row) => Review(
      str(row, 'author'),
      str(row, 'when_label'),
      dbl(row, 'rating', 5),
      str(row, 'body'),
    );

ServicePro providerFromRow(
  Map<String, dynamic> row, {
  List<Expertise> expertise = const [],
  List<Review> testimonials = const [],
}) =>
    ServicePro(
      id: str(row, 'id'),
      name: str(row, 'name'),
      profession: str(row, 'profession'),
      category: str(row, 'category'),
      professionColor: colorFromHex(strOrNull(row, 'profession_color')),
      rating: dbl(row, 'rating'),
      reviews: integer(row, 'reviews'),
      years: integer(row, 'years'),
      distance: dbl(row, 'distance'),
      photo: str(row, 'photo'),
      about: str(row, 'about'),
      expertise: expertise,
      email: str(row, 'email'),
      phone: str(row, 'phone'),
      office: str(row, 'office'),
      operatingArea: str(row, 'operating_area'),
      testimonials: testimonials,
    );

// ---------------------------------------------------------------- offers

Offer offerFromRow(Map<String, dynamic> row) => Offer(
      code: str(row, 'code'),
      title: str(row, 'title'),
      subtitle: str(row, 'subtitle'),
      image: str(row, 'image'),
      colors: [
        colorFromHex(strOrNull(row, 'color_start')),
        colorFromHex(strOrNull(row, 'color_end'), AppColors.primaryLight),
      ],
      validTill: str(row, 'valid_till'),
    );

// ---------------------------------------------------------------- bookings

const _statusNames = <String, BookingStatus>{
  'confirmed': BookingStatus.confirmed,
  'processing': BookingStatus.processing,
  'completed': BookingStatus.completed,
};

Booking bookingFromRow(Map<String, dynamic> row) => Booking(
      id: str(row, 'id'),
      title: str(row, 'title'),
      subtitle: str(row, 'subtitle'),
      kind: str(row, 'kind'),
      when: str(row, 'when_label'),
      status: _statusNames[str(row, 'status')] ?? BookingStatus.confirmed,
      image: str(row, 'image'),
      location: strOrNull(row, 'location'),
      reference: strOrNull(row, 'reference'),
    );

/// The insert payload for a booking. `id` and `user_id` are left to the
/// database, which fills them from `gen_random_uuid()` and `auth.uid()`.
Map<String, dynamic> bookingToRow(Booking booking) => {
      'title': booking.title,
      'subtitle': booking.subtitle,
      'kind': booking.kind,
      'when_label': booking.when,
      'status': booking.status.name,
      'image': booking.image,
      'location': booking.location,
      'reference': booking.reference,
    };
