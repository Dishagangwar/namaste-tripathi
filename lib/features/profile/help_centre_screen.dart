import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme.dart';
import '../../core/widgets.dart';

/// Placeholders: replace with the real support contacts before release.
const kSupportEmail = 'support@namastetripathi.example';
const kSupportPhone = '+91 00000 00000';

const _faqs = <(String, String)>[
  (
    'How do I track my order?',
    'Open the Orders tab. Your latest order shows its progress from '
        'Confirmed to Out for delivery.',
  ),
  (
    'Can I cancel a booking?',
    'Yes. Open Bookings, choose the booking and tap Cancel. Cancelling is '
        'free until the booking starts.',
  ),
  (
    'How do I change my delivery address?',
    'Tap the address at the top of Home, or manage them under '
        'Profile > Saved addresses.',
  ),
  (
    'How do I use a coupon?',
    'Tap a code on the Offers tab to copy it, then paste it in your basket '
        'at checkout.',
  ),
  (
    'Which payment methods are accepted?',
    'UPI, cards, netbanking and cash on delivery.',
  ),
];

class HelpCentreScreen extends StatelessWidget {
  const HelpCentreScreen({super.key});

  void _copy(BuildContext context, String label, String value) {
    Clipboard.setData(ClipboardData(text: value));
    showAppSnack(context, '$label copied.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help centre')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(4, 4, 4, 10),
            child: Text('FREQUENTLY ASKED',
                style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                    color: AppColors.muted)),
          ),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (final (q, a) in _faqs)
                  ExpansionTile(
                    shape: const Border(),
                    collapsedShape: const Border(),
                    title: Text(q,
                        style: const TextStyle(
                            fontSize: 14.5, fontWeight: FontWeight.w600)),
                    childrenPadding:
                        const EdgeInsets.fromLTRB(16, 0, 16, 14),
                    expandedCrossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(a,
                          style: const TextStyle(
                              fontSize: 13.5, color: AppColors.muted)),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const Padding(
            padding: EdgeInsets.fromLTRB(4, 0, 4, 10),
            child: Text('STILL NEED HELP?',
                style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                    color: AppColors.muted)),
          ),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.mail_outline_rounded,
                      color: AppColors.primary),
                  title: const Text(kSupportEmail),
                  subtitle: const Text('Tap to copy'),
                  onTap: () => _copy(context, 'Email', kSupportEmail),
                ),
                const Divider(indent: 56, height: 1),
                ListTile(
                  leading: const Icon(Icons.phone_outlined,
                      color: AppColors.primary),
                  title: const Text(kSupportPhone),
                  subtitle: const Text('Tap to copy'),
                  onTap: () => _copy(context, 'Phone number', kSupportPhone),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
