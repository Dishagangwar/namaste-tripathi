import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/bookings/bookings_bloc.dart';
import '../../bloc/favourites/favourites_bloc.dart';
import '../../bloc/session/session_bloc.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../auth/onboarding_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionBloc>().state;
    final bookings = context.watch<BookingsBloc>().state.items.length;
    final favs = context.watch<FavouritesBloc>().state.propertyIds.length;

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF7A4F00), Color(0xFFA87C0A)],
              ),
              boxShadow: kLiftShadow,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.white,
                      child: Text(
                        session.name.characters.first,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            session.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 21,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            session.phone.isEmpty
                                ? 'Signed in with Google'
                                : '${session.countryCode} ${session.phone}',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 13),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 11, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              session.role == JoinRole.user
                                  ? 'USER ACCOUNT'
                                  : 'SERVICE PROVIDER',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9.5,
                                letterSpacing: 0.7,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(child: _Stat('$bookings', 'Bookings')),
                    Container(
                      width: 1,
                      height: 34,
                      color: Colors.white24,
                    ),
                    Expanded(child: _Stat('$favs', 'Saved')),
                    Container(
                      width: 1,
                      height: 34,
                      color: Colors.white24,
                    ),
                    const Expanded(child: _Stat('4', 'Coupons')),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          for (final section in _sections) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 6, 4, 10),
              child: Text(
                section.$1,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                  color: AppColors.muted,
                ),
              ),
            ),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (var i = 0; i < section.$2.length; i++) ...[
                    ListTile(
                      leading: Icon(section.$2[i].$1,
                          size: 21, color: AppColors.primary),
                      title: Text(
                        section.$2[i].$2,
                        style: const TextStyle(
                            fontSize: 14.5, fontWeight: FontWeight.w600),
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded,
                          color: AppColors.faint),
                      onTap: () => showAppSnack(
                          context, '${section.$2[i].$2} coming soon.'),
                    ),
                    if (i != section.$2.length - 1)
                      const Divider(indent: 56, height: 1),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 18),
          ],
          OutlinedButton(
            // Ends the Supabase session before unwinding to onboarding, so
            // the next person on this device starts clean.
            onPressed: () async {
              final navigator = Navigator.of(context);
              context.read<SessionBloc>().add(const SessionSignedOut());
              navigator.pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const OnboardingScreen()),
                (_) => false,
              );
            },
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              foregroundColor: AppColors.danger,
              side: const BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
  }

  static const _sections = <(String, List<(IconData, String)>)>[
    (
      'ACCOUNT',
      [
        (Icons.person_outline_rounded, 'Edit profile'),
        (Icons.location_on_outlined, 'Saved addresses'),
        (Icons.payment_rounded, 'Payment methods'),
      ],
    ),
    (
      'PREFERENCES',
      [
        (Icons.notifications_none_rounded, 'Notifications'),
        (Icons.language_rounded, 'Language'),
        (Icons.dark_mode_outlined, 'Appearance'),
      ],
    ),
    (
      'SUPPORT',
      [
        (Icons.support_agent_rounded, 'Help centre'),
        (Icons.shield_outlined, 'Privacy policy'),
        (Icons.description_outlined, 'Terms of service'),
      ],
    ),
  ];
}

class _Stat extends StatelessWidget {
  const _Stat(this.value, this.label);
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}
