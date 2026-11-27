import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/preferences/preferences_cubit.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PreferencesCubit>();
    final s = context.watch<PreferencesCubit>().state;

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Order updates'),
            subtitle: const Text('Confirmed, out for delivery, delivered'),
            value: s.orderUpdates,
            onChanged: cubit.setOrderUpdates,
          ),
          SwitchListTile(
            title: const Text('Booking updates'),
            subtitle: const Text('Stays, rides and service visits'),
            value: s.bookingUpdates,
            onChanged: cubit.setBookingUpdates,
          ),
          SwitchListTile(
            title: const Text('Offers and promotions'),
            subtitle: const Text('New coupons and deals near you'),
            value: s.offers,
            onChanged: cubit.setOffers,
          ),
        ],
      ),
    );
  }
}
