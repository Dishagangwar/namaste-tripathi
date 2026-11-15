import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/models.dart';

class BookingConfirmedScreen extends StatelessWidget {
  const BookingConfirmedScreen({
    super.key,
    required this.booking,
    required this.total,
    required this.guestName,
  });

  final Booking booking;
  final double total;
  final String guestName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 34, 16, 24),
          children: [
            Center(
              child: Container(
                width: 82,
                height: 82,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      blurRadius: 28,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: const Icon(Icons.check_rounded,
                    color: Colors.white, size: 42),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Your stay is\nconfirmed',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 27, fontWeight: FontWeight.w800, height: 1.25),
            ),
            const SizedBox(height: 12),
            Text(
              'We have sent the confirmation to $guestName.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: AppColors.muted),
            ),
            const SizedBox(height: 28),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  SizedBox(
                    height: 170,
                    width: double.infinity,
                    child: AppImage(booking.image),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.title,
                          style: const TextStyle(
                              fontSize: 19, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          booking.subtitle,
                          style: const TextStyle(
                              fontSize: 13, color: AppColors.muted),
                        ),
                        const SizedBox(height: 16),
                        IconLabel(Icons.calendar_month_rounded, booking.when),
                        const SizedBox(height: 8),
                        IconLabel(Icons.location_on_rounded,
                            booking.location ?? ''),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Divider(),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
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
                                  booking.reference ?? '',
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                            Text(
                              rupees(total, decimals: true),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () =>
                  Navigator.of(context).popUntil((r) => r.isFirst),
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }
}
