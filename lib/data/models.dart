import 'package:flutter/material.dart';

class ServiceCategory {
  const ServiceCategory(this.id, this.label, this.icon);
  final String id;
  final String label;
  final IconData icon;
}

class Restaurant {
  const Restaurant({
    required this.id,
    required this.name,
    required this.cuisine,
    required this.rating,
    required this.deliveryTime,
    required this.costForTwo,
    required this.image,
    required this.tags,
    this.freeDelivery = true,
    this.badge,
    required this.menu,
  });

  final String id;
  final String name;
  final String cuisine;
  final double rating;
  final String deliveryTime;
  final int costForTwo;
  final String image;
  final List<String> tags;
  final bool freeDelivery;
  final String? badge;
  final List<MenuItem> menu;
}

class MenuItem {
  const MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    required this.category,
    this.isVeg = true,
  });

  final String id;
  final String name;
  final String description;
  final double price;
  final String image;
  final String category;
  final bool isVeg;
}

/// Immutable so it can live inside a bloc state: mutating a line in place
/// would change the old state object too, and Equatable would then see no
/// difference and skip the rebuild.
class CartLine {
  const CartLine(this.item, this.quantity);
  final MenuItem item;
  final int quantity;
  double get total => item.price * quantity;

  CartLine copyWith({int? quantity}) =>
      CartLine(item, quantity ?? this.quantity);
}

class Coupon {
  const Coupon(this.code, this.description, this.flat, this.percent, this.minOrder);
  final String code;
  final String description;
  final double flat;
  final double percent;
  final double minOrder;

  double discountOn(double subtotal) {
    if (subtotal < minOrder) return 0;
    if (percent > 0) return subtotal * percent / 100;
    return flat;
  }
}

class Hotel {
  const Hotel({
    required this.id,
    required this.name,
    required this.category,
    required this.rating,
    required this.reviews,
    required this.location,
    required this.distance,
    required this.pricePerNight,
    required this.image,
    required this.gallery,
    required this.amenities,
    required this.tagline,
    required this.description,
    this.discountPercent = 0,
  });

  final String id;
  final String name;
  final String category;
  final double rating;
  final int reviews;
  final String location;
  final String distance;
  final int pricePerNight;
  final String image;
  final List<String> gallery;
  final List<String> amenities;
  final String tagline;
  final String description;
  final int discountPercent;
}

class Property {
  const Property({
    required this.id,
    required this.name,
    required this.location,
    required this.price,
    required this.beds,
    required this.baths,
    required this.area,
    required this.image,
    required this.gallery,
    required this.tags,
    required this.description,
    this.forRent = false,
    this.monthlyRent = 0,
    this.configuration = '',
  });

  final String id;
  final String name;
  final String location;
  final int price;
  final int beds;
  final int baths;
  final int area;
  final String image;
  final List<String> gallery;
  final List<String> tags;
  final String description;
  final bool forRent;
  final int monthlyRent;
  final String configuration;
}

class ServicePro {
  const ServicePro({
    required this.id,
    required this.name,
    required this.profession,
    required this.category,
    required this.professionColor,
    required this.rating,
    required this.reviews,
    required this.years,
    required this.distance,
    required this.photo,
    required this.about,
    required this.expertise,
    required this.email,
    required this.phone,
    required this.office,
    required this.operatingArea,
    required this.testimonials,
  });

  final String id;
  final String name;
  final String profession;
  final String category;
  final Color professionColor;
  final double rating;
  final int reviews;
  final int years;
  final double distance;
  final String photo;
  final String about;
  final List<Expertise> expertise;
  final String email;
  final String phone;
  final String office;
  final String operatingArea;
  final List<Review> testimonials;
}

class Expertise {
  const Expertise(this.label, this.icon);
  final String label;
  final IconData icon;
}

class Review {
  const Review(this.name, this.when, this.rating, this.body);
  final String name;
  final String when;
  final double rating;
  final String body;
}

enum BookingStatus { confirmed, processing, completed }

class Booking {
  const Booking({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.kind,
    required this.when,
    required this.status,
    required this.image,
    this.location,
    this.reference,
  });

  final String id;
  final String title;
  final String subtitle;
  final String kind;
  final String when;
  final BookingStatus status;
  final String image;
  final String? location;
  final String? reference;
}

class Offer {
  const Offer({
    required this.code,
    required this.title,
    required this.subtitle,
    required this.image,
    required this.colors,
    required this.validTill,
  });

  final String code;
  final String title;
  final String subtitle;
  final String image;
  final List<Color> colors;
  final String validTill;
}

// ---------------------------------------------------------------- bike taxi

/// A class of ride the user can pick. Served by the backend so fares and
/// ETAs can change without shipping a build.
class RideOption {
  const RideOption({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.eta,
    required this.pricePerKm,
  });

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String eta;
  final int pricePerKm;

  /// The base fare is the flag-down charge every ride carries.
  static const baseFare = 15;

  int fareFor(double distanceKm) =>
      (pricePerKm * distanceKm).round() + baseFare;
}

enum RideStatus { searching, assigned, completed, cancelled }

/// A ride the user has asked for.
class Ride {
  const Ride({
    required this.id,
    required this.optionId,
    required this.rideType,
    required this.fromAddress,
    required this.toAddress,
    required this.distanceKm,
    required this.fare,
    required this.eta,
    this.status = RideStatus.searching,
    this.reference,
  });

  final String id;
  final String optionId;
  final String rideType;
  final String fromAddress;
  final String toAddress;
  final double distanceKm;
  final int fare;
  final String eta;
  final RideStatus status;
  final String? reference;

  Ride copyWith({String? id, RideStatus? status, String? reference}) => Ride(
        id: id ?? this.id,
        optionId: optionId,
        rideType: rideType,
        fromAddress: fromAddress,
        toAddress: toAddress,
        distanceKm: distanceKm,
        fare: fare,
        eta: eta,
        status: status ?? this.status,
        reference: reference ?? this.reference,
      );
}

// ---------------------------------------------------------------- orders

/// One line of a placed order. Captured at the price paid, not the price the
/// menu shows today.
class OrderLine {
  const OrderLine({
    required this.itemId,
    required this.name,
    required this.quantity,
    required this.price,
  });

  final String itemId;
  final String name;
  final int quantity;
  final double price;

  double get total => price * quantity;

  String get label => '$quantity × $name';
}

enum OrderStatus { placed, preparing, onTheWay, delivered, cancelled }

/// A food order, with the bill frozen as it was at checkout.
class FoodOrder {
  const FoodOrder({
    required this.id,
    required this.restaurantId,
    required this.restaurantName,
    required this.image,
    required this.lines,
    required this.subtotal,
    required this.deliveryFee,
    required this.taxes,
    required this.discount,
    required this.total,
    required this.paymentMethod,
    this.couponCode,
    this.instructions = const [],
    this.status = OrderStatus.placed,
    this.reference,
    this.placedAt,
  });

  final String id;
  final String restaurantId;
  final String restaurantName;
  final String image;
  final List<OrderLine> lines;
  final double subtotal;
  final double deliveryFee;
  final double taxes;
  final double discount;
  final double total;
  final String paymentMethod;
  final String? couponCode;
  final List<String> instructions;
  final OrderStatus status;
  final String? reference;
  final DateTime? placedAt;

  int get itemCount => lines.fold(0, (sum, l) => sum + l.quantity);

  FoodOrder copyWith({String? id, OrderStatus? status, String? reference}) =>
      FoodOrder(
        id: id ?? this.id,
        restaurantId: restaurantId,
        restaurantName: restaurantName,
        image: image,
        lines: lines,
        subtotal: subtotal,
        deliveryFee: deliveryFee,
        taxes: taxes,
        discount: discount,
        total: total,
        paymentMethod: paymentMethod,
        couponCode: couponCode,
        instructions: instructions,
        status: status ?? this.status,
        reference: reference ?? this.reference,
        placedAt: placedAt,
      );
}

// ---------------------------------------------------------------- config

/// A shortcut address offered when choosing a location or a destination.
class SavedPlace {
  const SavedPlace({
    required this.id,
    required this.icon,
    required this.label,
    required this.address,
  });

  final String id;
  final IconData icon;
  final String label;
  final String address;
}

/// The keys the backend groups filter chips under.
class FilterGroup {
  const FilterGroup._();

  static const cuisine = 'cuisine';
  static const hotel = 'hotel';
  static const property = 'property';
  static const provider = 'provider';
}

/// Everything about the app that is taxonomy rather than catalogue: the
/// service tiles, the filter chips, the saved addresses, the ride classes and
/// the editorial copy.
///
/// It is one payload and one request because it is all read at startup and
/// none of it is user-specific.
class AppConfig {
  const AppConfig({
    required this.categories,
    required this.wideCategory,
    required this.savedPlaces,
    required this.rideOptions,
    required this.filters,
    required this.travelerTip,
  });

  final List<ServiceCategory> categories;
  final ServiceCategory wideCategory;
  final List<SavedPlace> savedPlaces;
  final List<RideOption> rideOptions;
  final Map<String, List<String>> filters;
  final String travelerTip;

  /// Falls back to 'All' alone so a screen whose group is missing still has a
  /// usable chip row rather than an empty strip.
  List<String> filtersFor(String group) =>
      filters[group] ?? const ['All'];
}
