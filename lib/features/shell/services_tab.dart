import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/config/config_bloc.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../biketaxi/bike_taxi_screen.dart';
import '../food/food_list_screen.dart';
import '../hotels/hotels_list_screen.dart';
import '../providers/providers_list_screen.dart';
import 'global_search_screen.dart';
import 'main_shell.dart';

/// Hosts whichever module the user picked. Keeping it inside the tab means the
/// five-item bottom bar stays on screen, matching the recording.
class ServicesTab extends StatelessWidget {
  const ServicesTab({super.key, required this.module, required this.onClose});

  final String? module;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    switch (module) {
      case 'food':
        return FoodListScreen(onBack: onClose);
      case 'hotel':
        return HotelsListScreen(onBack: onClose);
      case 'providers':
        return ProvidersListScreen(onBack: onClose);
      case 'bike':
        return BikeTaxiScreen(onBack: onClose);
      case 'search':
        return GlobalSearchScreen(onBack: onClose);
      default:
        return const _ServicesHub();
    }
  }
}

class _ServicesHub extends StatelessWidget {
  const _ServicesHub();

  @override
  Widget build(BuildContext context) {
    final shell = MainShell.of(context);
    final config = context.watch<ConfigBloc>().state;
    final all = [...config.categories, config.wideCategory];

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 26),
        children: [
          const Text(
            'All Services',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          const Text(
            'Everything your city has to offer, in one place.',
            style: TextStyle(fontSize: 14, color: AppColors.muted),
          ),
          const SizedBox(height: 22),
          for (final c in all) ...[
            AppCard(
              onTap: () => shell.openModule(c.id),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  SoftIconBox(c.icon, size: 48, iconSize: 23),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          c.label,
                          style: const TextStyle(
                              fontSize: 15.5, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _blurbs[c.id] ?? '',
                          style: const TextStyle(
                              fontSize: 12.5, color: AppColors.muted),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded,
                      color: AppColors.faint),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }

  static const _blurbs = {
    'food': 'Restaurants, cafes and late-night kitchens',
    'hotel': 'Stays from heritage havelis to beach resorts',
    'realestate': 'Buy, rent and book site visits',
    'bike': 'Bike taxi, e-rickshaw, parcels and cabs',
    'providers': 'Verified electricians, plumbers and more',
  };
}

/// Simple header used by every module list inside the Services tab.
class ModuleHeader extends StatelessWidget {
  const ModuleHeader({
    super.key,
    required this.title,
    required this.onBack,
    this.trailing,
    this.centerTitle = true,
  });

  final String title;
  final VoidCallback onBack;
  final Widget? trailing;
  final bool centerTitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 6, 12, 6),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded),
            color: AppColors.text,
          ),
          Expanded(
            child: Align(
              alignment:
                  centerTitle ? Alignment.center : Alignment.centerLeft,
              child: Text(
                title,
                style: TextStyle(
                  fontSize: centerTitle ? 18 : 21,
                  fontWeight: FontWeight.w800,
                  color: centerTitle ? AppColors.primary : AppColors.text,
                ),
              ),
            ),
          ),
          SizedBox(width: 48, child: trailing),
        ],
      ),
    );
  }
}
