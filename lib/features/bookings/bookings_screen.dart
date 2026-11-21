import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/bookings/bookings_bloc.dart';
import '../../bloc/config/config_bloc.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/models.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  @override
  void initState() {
    super.initState();
    // Pulls this user's own bookings from Supabase; a no-op when signed out,
    // which leaves the sample itinerary on screen.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<BookingsBloc>().add(const BookingsRequested());
    });
  }

  @override
  Widget build(BuildContext context) {
    final bookings = context.watch<BookingsBloc>().state.items;

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: Text(
              'My Bookings',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async =>
                  context.read<BookingsBloc>().add(const BookingsRequested()),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
                children: [
                  for (final b in bookings) ...[
                    _BookingCard(booking: b),
                    const SizedBox(height: 16),
                  ],
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDF5DD),
                      borderRadius: BorderRadius.circular(AppRadius.card),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.lightbulb_outline_rounded,
                              size: 21, color: AppColors.primary),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Traveler Tip',
                                  style: TextStyle(
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.w700)),
                              const SizedBox(height: 7),
                              Text(
                                context.watch<ConfigBloc>().state.travelerTip,
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.muted,
                                    height: 1.6),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.booking});
  final Booking booking;

  (String, Color, Color) get _status => switch (booking.status) {
        BookingStatus.confirmed => (
            'Confirmed',
            Colors.white,
            AppColors.text,
          ),
        BookingStatus.processing => (
            'Processing',
            AppColors.primaryLight,
            Colors.white,
          ),
        BookingStatus.completed => (
            'Completed',
            AppColors.successBg,
            AppColors.success,
          ),
      };

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = _status;

    return AppCard(
      padding: EdgeInsets.zero,
      onTap: () => showAppSnack(
          context, '${booking.title} — ${booking.reference}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              SizedBox(
                height: 164,
                width: double.infinity,
                child: AppImage(booking.image),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 13, vertical: 7),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: kSoftShadow,
                  ),
                  child: Text(
                    label.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 0.6,
                      fontWeight: FontWeight.w700,
                      color: fg,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(_kindIcon(booking.kind),
                        size: 16, color: AppColors.primary),
                    const SizedBox(width: 7),
                    Text(
                      booking.kind.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10.5,
                        letterSpacing: 0.7,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  booking.title,
                  style: const TextStyle(
                      fontSize: 19, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                IconLabel(Icons.calendar_month_rounded, booking.when),
                if (booking.location != null) ...[
                  const SizedBox(height: 6),
                  IconLabel(Icons.location_on_rounded, booking.location!),
                ],
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'REFERENCE',
                            style: TextStyle(
                              fontSize: 9.5,
                              letterSpacing: 0.8,
                              fontWeight: FontWeight.w600,
                              color: AppColors.muted,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            booking.reference ?? '—',
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                    FilledButton(
                      onPressed: () => showAppSnack(
                          context, 'Opening ${booking.title}.'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(132, 46),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('View Details',
                          style: TextStyle(fontSize: 13.5)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static IconData _kindIcon(String kind) => switch (kind) {
        'Luxury Stay' => Icons.king_bed_rounded,
        'Wellness' => Icons.spa_rounded,
        'Dining' => Icons.restaurant_rounded,
        'Property Visit' => Icons.home_work_rounded,
        _ => Icons.handyman_rounded,
      };
}
