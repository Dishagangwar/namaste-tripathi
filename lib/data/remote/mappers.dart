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

// ---------------------------------------------------------------- orders

const _orderStatusNames = <String, OrderStatus>{
  'placed': OrderStatus.placed,
  'preparing': OrderStatus.preparing,
  'on_the_way': OrderStatus.onTheWay,
  'delivered': OrderStatus.delivered,
  'cancelled': OrderStatus.cancelled,
};

/// `onTheWay` is `on_the_way` on the wire, so the enum name cannot be used
/// directly in either direction.
String orderStatusToWire(OrderStatus status) => switch (status) {
      OrderStatus.placed => 'placed',
      OrderStatus.preparing => 'preparing',
      OrderStatus.onTheWay => 'on_the_way',
      OrderStatus.delivered => 'delivered',
      OrderStatus.cancelled => 'cancelled',
    };

OrderLine orderLineFromRow(Map<String, dynamic> row) => OrderLine(
      itemId: str(row, 'item_id'),
      name: str(row, 'name'),
      quantity: integer(row, 'quantity', 1),
      price: dbl(row, 'price'),
    );

Map<String, dynamic> orderLineToRow(OrderLine line) => {
      'item_id': line.itemId,
      'name': line.name,
      'quantity': line.quantity,
      'price': line.price,
    };

FoodOrder orderFromRow(Map<String, dynamic> row) => FoodOrder(
      id: str(row, 'id'),
      restaurantId: str(row, 'restaurant_id'),
      restaurantName: str(row, 'restaurant_name'),
      image: str(row, 'image'),
      lines: [
        for (final line in (row['lines'] as List? ?? const []))
          if (line is Map) orderLineFromRow(Map<String, dynamic>.from(line)),
      ],
      subtotal: dbl(row, 'subtotal'),
      deliveryFee: dbl(row, 'delivery_fee'),
      taxes: dbl(row, 'taxes'),
      discount: dbl(row, 'discount'),
      total: dbl(row, 'total'),
      paymentMethod: str(row, 'payment_method', 'gpay'),
      couponCode: strOrNull(row, 'coupon_code'),
      instructions: strList(row, 'instructions'),
      status: _orderStatusNames[str(row, 'status')] ?? OrderStatus.placed,
      reference: strOrNull(row, 'reference'),
      placedAt: DateTime.tryParse(str(row, 'created_at')),
    );

/// The insert payload. `id` is the server's to assign, so it is not sent.
Map<String, dynamic> orderToRow(FoodOrder order) => {
      'restaurant_id': order.restaurantId,
      'restaurant_name': order.restaurantName,
      'image': order.image,
      'lines': order.lines.map(orderLineToRow).toList(),
      'subtotal': order.subtotal,
      'delivery_fee': order.deliveryFee,
      'taxes': order.taxes,
      'discount': order.discount,
      'total': order.total,
      'payment_method': order.paymentMethod,
      'coupon_code': order.couponCode,
      'instructions': order.instructions,
      'status': orderStatusToWire(order.status),
    };

// ---------------------------------------------------------------- rides

const _rideStatusNames = <String, RideStatus>{
  'searching': RideStatus.searching,
  'assigned': RideStatus.assigned,
  'completed': RideStatus.completed,
  'cancelled': RideStatus.cancelled,
};

RideOption rideOptionFromRow(Map<String, dynamic> row) => RideOption(
      id: str(row, 'id'),
      title: str(row, 'title'),
      subtitle: str(row, 'subtitle'),
      icon: iconFromName(strOrNull(row, 'icon')),
      color: colorFromHex(strOrNull(row, 'color')),
      eta: str(row, 'eta'),
      pricePerKm: integer(row, 'price_per_km', 10),
    );

Ride rideFromRow(Map<String, dynamic> row) => Ride(
      id: str(row, 'id'),
      optionId: str(row, 'option_id'),
      rideType: str(row, 'ride_type'),
      fromAddress: str(row, 'from_address'),
      toAddress: str(row, 'to_address'),
      distanceKm: dbl(row, 'distance_km'),
      fare: integer(row, 'fare'),
      eta: str(row, 'eta'),
      status: _rideStatusNames[str(row, 'status')] ?? RideStatus.searching,
      reference: strOrNull(row, 'reference'),
    );

Map<String, dynamic> rideToRow(Ride ride) => {
      'option_id': ride.optionId,
      'ride_type': ride.rideType,
      'from_address': ride.fromAddress,
      'to_address': ride.toAddress,
      'distance_km': ride.distanceKm,
      'fare': ride.fare,
      'eta': ride.eta,
      'status': ride.status.name,
    };

// ---------------------------------------------------------------- config

ServiceCategory categoryFromRow(Map<String, dynamic> row) => ServiceCategory(
      str(row, 'id'),
      str(row, 'label'),
      iconFromName(strOrNull(row, 'icon')),
    );

SavedPlace savedPlaceFromRow(Map<String, dynamic> row) => SavedPlace(
      id: str(row, 'id'),
      icon: iconFromName(strOrNull(row, 'icon')),
      label: str(row, 'label'),
      address: str(row, 'address'),
    );

/// Parses the whole `/config` payload, falling back field by field to the
/// bundled taxonomy so a backend that serves only part of it still works.
///
/// The service tiles arrive as one list with an `is_wide` flag, because they
/// are one table; the app wants them split into the grid and the wide tile.
AppConfig appConfigFromRow(Map<String, dynamic> row, AppConfig fallback) {
  final rows = [
    for (final c in (row['categories'] as List? ?? const []))
      if (c is Map) Map<String, dynamic>.from(c),
  ];

  final grid = [
    for (final c in rows)
      if (!boolean(c, 'is_wide')) categoryFromRow(c),
  ];
  final wide = [
    for (final c in rows)
      if (boolean(c, 'is_wide')) categoryFromRow(c),
  ];

  final places = [
    for (final p in (row['saved_places'] as List? ?? const []))
      if (p is Map) savedPlaceFromRow(Map<String, dynamic>.from(p)),
  ];

  final rides = [
    for (final r in (row['ride_options'] as List? ?? const []))
      if (r is Map) rideOptionFromRow(Map<String, dynamic>.from(r)),
  ];

  final filters = <String, List<String>>{};
  final rawFilters = row['filters'];
  if (rawFilters is Map) {
    for (final entry in rawFilters.entries) {
      final value = entry.value;
      if (value is! List) continue;
      final labels = [
        for (final label in value)
          if (label != null) label.toString(),
      ];
      if (labels.isNotEmpty) filters[entry.key.toString()] = labels;
    }
  }

  final tip = strOrNull(row, 'traveler_tip');

  return AppConfig(
    categories: grid.isEmpty ? fallback.categories : grid,
    wideCategory: wide.isEmpty ? fallback.wideCategory : wide.first,
    savedPlaces: places.isEmpty ? fallback.savedPlaces : places,
    rideOptions: rides.isEmpty ? fallback.rideOptions : rides,
    filters: filters.isEmpty ? fallback.filters : filters,
    travelerTip: tip ?? fallback.travelerTip,
  );
}
