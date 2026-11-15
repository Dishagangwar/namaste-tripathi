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

class CartLine {
  CartLine(this.item, this.quantity);
  final MenuItem item;
  int quantity;
  double get total => item.price * quantity;
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
