import 'package:flutter/material.dart';

/// Icons cannot travel over the wire, so Supabase stores a short name and the
/// app resolves it here. An unknown name falls back to a neutral icon rather
/// than crashing a detail screen, which keeps content editing in the
/// dashboard safe.
const kIconRegistry = <String, IconData>{
  'accessibility_new': Icons.accessibility_new_rounded,
  'auto_awesome': Icons.auto_awesome_outlined,
  'bathtub': Icons.bathtub_outlined,
  'battery_charging_full': Icons.battery_charging_full_rounded,
  'bolt': Icons.bolt_rounded,
  'brush': Icons.brush_outlined,
  'build_circle': Icons.build_circle_outlined,
  'calculate': Icons.calculate_outlined,
  'calendar_month': Icons.calendar_month_rounded,
  'chat_bubble': Icons.chat_bubble_outline_rounded,
  'cleaning_services': Icons.cleaning_services_rounded,
  'content_cut': Icons.content_cut_rounded,
  'disc_full': Icons.disc_full_outlined,
  'electric_rickshaw': Icons.electric_rickshaw,
  'electrical_services': Icons.electrical_services_rounded,
  'event_repeat': Icons.event_repeat_rounded,
  'favorite_outline': Icons.favorite_outline_rounded,
  'fitness_center': Icons.fitness_center_rounded,
  'flight': Icons.flight_rounded,
  'handyman': Icons.handyman_rounded,
  'healing': Icons.healing_rounded,
  'home': Icons.home_rounded,
  'hot_tub': Icons.hot_tub_rounded,
  'inventory_2': Icons.inventory_2_outlined,
  'king_bed': Icons.king_bed_rounded,
  'kitchen': Icons.kitchen_outlined,
  'lightbulb_outline': Icons.lightbulb_outline_rounded,
  'local_car_wash': Icons.local_car_wash_outlined,
  'local_shipping': Icons.local_shipping_outlined,
  'local_taxi': Icons.local_taxi_rounded,
  'monitor_heart': Icons.monitor_heart_outlined,
  'moving': Icons.moving_rounded,
  'palette': Icons.palette_outlined,
  'plumbing': Icons.plumbing_rounded,
  'receipt_long': Icons.receipt_long_rounded,
  'restaurant': Icons.restaurant_rounded,
  'restaurant_menu': Icons.restaurant_menu_rounded,
  'sanitizer': Icons.sanitizer_outlined,
  'settings': Icons.settings_rounded,
  'settings_suggest': Icons.settings_suggest_rounded,
  'solar_power': Icons.solar_power_rounded,
  'store_mall_directory': Icons.store_mall_directory_outlined,
  'two_wheeler': Icons.two_wheeler_rounded,
  'verified_user': Icons.verified_user_outlined,
  'water_damage': Icons.water_damage_outlined,
  'water_drop': Icons.water_drop_outlined,
  'weekend': Icons.weekend_outlined,
  'work': Icons.work_rounded,
};

IconData iconFromName(String? name) =>
    kIconRegistry[name] ?? Icons.check_circle_outline_rounded;
