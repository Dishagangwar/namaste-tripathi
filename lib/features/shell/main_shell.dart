import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../bookings/bookings_screen.dart';
import '../home/home_screen.dart';
import '../offers/offers_screen.dart';
import '../profile/profile_screen.dart';
import '../realestate/realestate_shell.dart';
import 'services_tab.dart';

/// The five-tab container. Category tiles on Home switch to the Services tab
/// and open a module there, so the bottom bar stays visible exactly as it
/// does in the reference app.
class MainShell extends StatefulWidget {
  const MainShell({super.key, this.initialIndex = 0});
  final int initialIndex;

  static MainShellState of(BuildContext context) =>
      context.findAncestorStateOfType<MainShellState>()!;

  @override
  State<MainShell> createState() => MainShellState();
}

class MainShellState extends State<MainShell> {
  late int _index = widget.initialIndex;
  String? _module;

  void openModule(String id) {
    // Real estate runs its own navigation stack in the reference app, so it
    // opens full-screen rather than inside the Services tab.
    if (id == 'realestate') {
      Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(builder: (_) => const RealEstateShell()),
      );
      return;
    }
    setState(() {
      _module = id;
      _index = 1;
    });
  }

  void closeModule() => setState(() => _module = null);

  void goTo(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          const HomeScreen(),
          ServicesTab(module: _module, onClose: closeModule),
          const BookingsScreen(),
          const OffersScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        index: _index,
        onTap: (i) => setState(() {
          _index = i;
          if (i != 1) _module = null;
        }),
      ),
    );
  }
}

class NavSpec {
  const NavSpec(this.label, this.icon, this.activeIcon);
  final String label;
  final IconData icon;
  final IconData activeIcon;
}

const kMainNav = <NavSpec>[
  NavSpec('Home', Icons.home_outlined, Icons.home_rounded),
  NavSpec('Services', Icons.grid_view_outlined, Icons.grid_view_rounded),
  NavSpec('Bookings', Icons.calendar_today_outlined, Icons.calendar_month_rounded),
  NavSpec('Offers', Icons.local_offer_outlined, Icons.local_offer_rounded),
  NavSpec('Profile', Icons.person_outline_rounded, Icons.person_rounded),
];

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.index,
    required this.onTap,
    this.items = kMainNav,
  });

  final int index;
  final ValueChanged<int> onTap;
  final List<NavSpec> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3A2A05).withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: Row(
            children: List.generate(items.length, (i) {
              final active = i == index;
              final spec = items[i];
              return Expanded(
                child: InkWell(
                  onTap: () => onTap(i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        active ? spec.activeIcon : spec.icon,
                        size: 23,
                        color: active ? AppColors.primary : AppColors.faint,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        spec.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                          color: active ? AppColors.primary : AppColors.faint,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

/// Pill-style bottom bar used by the Food and Real-estate modules, which run
/// their own navigation in the reference app.
class ModuleBottomNav extends StatelessWidget {
  const ModuleBottomNav({
    super.key,
    required this.index,
    required this.onTap,
    required this.items,
  });

  final int index;
  final ValueChanged<int> onTap;
  final List<NavSpec> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 66,
          child: Row(
            children: List.generate(items.length, (i) {
              final active = i == index;
              final spec = items[i];
              return Expanded(
                child: InkWell(
                  onTap: () => onTap(i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 7),
                        decoration: BoxDecoration(
                          color: active ? AppColors.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Icon(
                          active ? spec.activeIcon : spec.icon,
                          size: 21,
                          color: active ? Colors.white : AppColors.faint,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        spec.label.toUpperCase(),
                        style: TextStyle(
                          fontSize: 9.5,
                          letterSpacing: 0.4,
                          fontWeight: active ? FontWeight.w700 : FontWeight.w600,
                          color: active ? AppColors.primary : AppColors.faint,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
