import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_state.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/mock_data.dart';
import 'food_list_screen.dart';

class FoodOrdersScreen extends StatelessWidget {
  const FoodOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final past = kRestaurants.take(3).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Your Orders')),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: past.length,
        separatorBuilder: (_, _) => const SizedBox(height: 14),
        itemBuilder: (_, i) {
          final r = past[i];
          final delivered = i > 0;
          return AppCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 56,
                      height: 56,
                      child: AppImage(r.image, radius: 12),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            r.name,
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${r.menu.first.name} × 1',
                            style: const TextStyle(
                                fontSize: 12.5, color: AppColors.muted),
                          ),
                        ],
                      ),
                    ),
                    Pill(
                      delivered ? 'Delivered' : 'On the way',
                      bg: delivered
                          ? AppColors.successBg
                          : AppColors.tintSurface,
                      fg: delivered ? AppColors.success : AppColors.primary,
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(),
                ),
                Row(
                  children: [
                    Text(
                      rupees(r.menu.first.price),
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                    const Spacer(),
                    OutlinedButton(
                      onPressed: () =>
                          showAppSnack(context, 'Reordering from ${r.name}.'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Reorder'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class FoodSavedScreen extends StatelessWidget {
  const FoodSavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favs = context.watch<FavouritesState>();
    final saved =
        kRestaurants.where((r) => favs.isRestaurantSaved(r.id)).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Saved')),
      body: saved.isEmpty
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bookmark_border_rounded,
                      size: 48, color: AppColors.faint),
                  SizedBox(height: 12),
                  Text('Nothing saved yet.',
                      style: TextStyle(color: AppColors.muted)),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: saved.length,
              separatorBuilder: (_, _) => const SizedBox(height: 16),
              itemBuilder: (_, i) => RestaurantCard(restaurant: saved[i]),
            ),
    );
  }
}

class FoodProfileScreen extends StatelessWidget {
  const FoodProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionState>();

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          AppCard(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.tintSurface,
                  child: Text(
                    session.name.characters.first,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        session.name,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${session.countryCode} ${session.phone}',
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          for (final row in const [
            (Icons.location_on_outlined, 'Saved addresses'),
            (Icons.payment_rounded, 'Payment methods'),
            (Icons.local_offer_outlined, 'Your coupons'),
            (Icons.support_agent_rounded, 'Help & support'),
          ])
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AppCard(
                onTap: () => showAppSnack(context, '${row.$2} coming soon.'),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Icon(row.$1, size: 21, color: AppColors.primary),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        row.$2,
                        style: const TextStyle(
                            fontSize: 14.5, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded,
                        color: AppColors.faint),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
