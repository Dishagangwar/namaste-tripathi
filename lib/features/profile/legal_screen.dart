import 'package:flutter/material.dart';

import '../../core/theme.dart';

/// A scrollable page of headed paragraphs, used for the privacy policy and
/// the terms of service.
///
/// The wording below is a plain-language starting point, not reviewed legal
/// text; have it checked before the app is released.
class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key, required this.title, required this.sections});

  final String title;
  final List<(String, String)> sections;

  static const privacy = LegalScreen(
    title: 'Privacy policy',
    sections: [
      (
        'What we collect',
        'Your name, phone number or Google account, the addresses you save, '
            'and your orders and bookings, so we can provide the service.',
      ),
      (
        'Location',
        'We use your location only when you ask to use your current location '
            'to set a delivery address. It is not tracked in the background.',
      ),
      (
        'Payments',
        'We never store a full card number. Saved cards keep only the last '
            'four digits.',
      ),
      (
        'Your choices',
        'You can edit or delete your saved addresses and payment methods '
            'from your profile at any time, and log out to end your session.',
      ),
    ],
  );

  static const terms = LegalScreen(
    title: 'Terms of service',
    sections: [
      (
        'Using the app',
        'Namaste Tripathi connects you with food, stays, rides, property '
            'and home services. You agree to provide accurate details.',
      ),
      (
        'Orders and bookings',
        'Orders and bookings are fulfilled by the listed partners. Prices '
            'and availability can change until a booking is confirmed.',
      ),
      (
        'Cancellations and refunds',
        'Cancellation rules depend on the service and are shown before you '
            'confirm. Eligible refunds go back to the original payment method.',
      ),
      (
        'Conduct',
        'Do not misuse the app, attempt to disrupt it, or use another '
            "person's account or payment details.",
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          for (final (heading, body) in sections) ...[
            Text(heading,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(body,
                style: const TextStyle(
                    fontSize: 14, height: 1.5, color: AppColors.muted)),
            const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }
}
