import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_state.dart';
import '../../core/catalog_state.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/mock_data.dart';
import '../../data/models.dart';
import '../food/restaurant_detail_screen.dart';
import '../hotels/hotel_detail_screen.dart';
import '../realestate/property_detail_screen.dart';
import '../shell/main_shell.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionState>();
    final catalog = context.watch<CatalogState>();
    final shell = MainShell.of(context);
    final rentals = catalog.properties.where((p) => p.forRent).toList();

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _TopBar(session: session)),
          const SliverToBoxAdapter(child: _HeroSearch()),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 22, 16, 0),
              child: _CategoryGrid(onOpen: shell.openModule),
            ),
          ),
          SliverToBoxAdapter(
            child: _Carousel(
              title: 'Top Restaurants',
              onSeeAll: () => shell.openModule('food'),
              children: catalog.restaurants
                  .take(5)
                  .map((r) => _RestaurantMini(restaurant: r))
                  .toList(),
            ),
          ),
          SliverToBoxAdapter(
            child: _Carousel(
              title: 'Top Hotels',
              onSeeAll: () => shell.openModule('hotel'),
              children: catalog.hotels
                  .take(5)
                  .map((h) => _HotelMini(hotel: h))
                  .toList(),
            ),
          ),
          // Skipped rather than crashed when the catalogue carries no
          // rentals, which an edited dashboard can easily produce.
          if (rentals.isNotEmpty)
            SliverToBoxAdapter(child: _RentalStrip(property: rentals.first)),
          SliverToBoxAdapter(
            child: _Carousel(
              title: 'Top Properties for Sale',
              onSeeAll: () => shell.openModule('realestate'),
              height: 252,
              children: catalog.properties
                  .where((p) => !p.forRent)
                  .take(5)
                  .map((p) => _PropertyMini(property: p))
                  .toList(),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 26)),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.session});
  final SessionState session;

  void _pickLocation(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Delivering to',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 8),
            for (final place in kSavedPlaces)
              ListTile(
                leading: SoftIconBox(place.$1, size: 42, iconSize: 20),
                title: Text(place.$2,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(place.$3,
                    style: const TextStyle(
                        fontSize: 12.5, color: AppColors.muted)),
                onTap: () {
                  session.setLocation(place.$2, place.$3);
                  Navigator.pop(context);
                },
              ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _pickLocation(context),
              behavior: HitTestBehavior.opaque,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_on_outlined,
                      size: 18, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      session.location,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 14.5, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down_rounded, size: 19),
                ],
              ),
            ),
          ),
          const Text(
            'Namaste Tripathi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () => showAppSnack(context, 'No new notifications.'),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: kSoftShadow,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(Icons.notifications_none_rounded,
                          size: 21, color: AppColors.primary),
                      Positioned(
                        top: 10,
                        right: 11,
                        child: Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: AppColors.danger,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroSearch extends StatelessWidget {
  const _HeroSearch();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Container(
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF7A4F00), Color(0xFFA87C0A)],
          ),
          boxShadow: kLiftShadow,
        ),
        child: Stack(
          children: [
            Positioned(
              right: -6,
              top: -4,
              child: _DotGrid(),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Find everything in',
                  style: TextStyle(
                      color: Colors.white, fontSize: 19, height: 1.25),
                ),
                const Text(
                  'your City',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 18),
                GestureDetector(
                  onTap: () => MainShell.of(context).openModule('search'),
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(26),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.search_rounded,
                            color: AppColors.faint, size: 21),
                        SizedBox(width: 10),
                        Text(
                          'Search for food, hotels, or rides',
                          style:
                              TextStyle(color: AppColors.faint, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DotGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.22,
      child: Column(
        children: List.generate(
          5,
          (_) => Row(
            children: List.generate(
              6,
              (_) => Container(
                width: 4,
                height: 4,
                margin: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({required this.onOpen});
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 1.22,
          children: [
            for (final c in kCategories)
              AppCard(
                onTap: () => onOpen(c.id),
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SoftIconBox(c.icon),
                    const SizedBox(height: 12),
                    Text(
                      c.label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 13.5, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 14),
        AppCard(
          onTap: () => onOpen('providers'),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SoftIconBox(kWideCategory.icon, size: 44, iconSize: 21),
              const SizedBox(width: 16),
              const Text(
                'Service Providers',
                style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Carousel extends StatelessWidget {
  const _Carousel({
    required this.title,
    required this.children,
    this.onSeeAll,
    this.height = 210,
  });

  final String title;
  final List<Widget> children;
  final VoidCallback? onSeeAll;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 28, 16, 14),
          child: SectionHeader(title, actionLabel: 'See all', onAction: onSeeAll),
        ),
        SizedBox(
          height: height,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: children.length,
            separatorBuilder: (_, _) => const SizedBox(width: 14),
            itemBuilder: (_, i) => children[i],
          ),
        ),
      ],
    );
  }
}

class _RestaurantMini extends StatelessWidget {
  const _RestaurantMini({required this.restaurant});
  final Restaurant restaurant;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 196,
      child: AppCard(
        padding: EdgeInsets.zero,
        onTap: () => Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(
            builder: (_) => RestaurantDetailScreen(restaurant: restaurant),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 118,
              width: double.infinity,
              child: AppImage(restaurant.image),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurant.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 14.5, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    restaurant.cuisine,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 11.5, color: AppColors.muted),
                  ),
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          size: 15, color: AppColors.star),
                      const SizedBox(width: 3),
                      Text(
                        restaurant.rating.toStringAsFixed(1),
                        style: const TextStyle(
                            fontSize: 12.5, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HotelMini extends StatelessWidget {
  const _HotelMini({required this.hotel});
  final Hotel hotel;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 196,
      child: AppCard(
        padding: EdgeInsets.zero,
        onTap: () => Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(builder: (_) => HotelDetailScreen(hotel: hotel)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                SizedBox(
                  height: 118,
                  width: double.infinity,
                  child: AppImage(hotel.image),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: RatingBadge(hotel.rating, onDark: true),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hotel.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 14.5, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    hotel.location,
                    style: const TextStyle(
                        fontSize: 11.5, color: AppColors.muted),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    '${rupees(hotel.pricePerNight)} / night',
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PropertyMini extends StatelessWidget {
  const _PropertyMini({required this.property});
  final Property property;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 230,
      child: AppCard(
        padding: EdgeInsets.zero,
        onTap: () => Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(
            builder: (_) => PropertyDetailScreen(property: property),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 140,
              width: double.infinity,
              child: AppImage(property.image),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          property.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 14.5, fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _shortPrice(property.price),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${property.location} • ${property.beds} Beds',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 11.5, color: AppColors.muted),
                  ),
                  const SizedBox(height: 8),
                  if (property.tags.contains('Premium'))
                    const Pill('Premium'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _shortPrice(int value) {
  if (value >= 10000000) {
    final cr = value / 10000000;
    return '₹${cr.toStringAsFixed(cr >= 10 ? 0 : 1)}Cr';
  }
  if (value >= 100000) {
    final l = value / 100000;
    return '₹${l.toStringAsFixed(l >= 10 ? 0 : 1)}L';
  }
  return rupees(value);
}

class _RentalStrip extends StatelessWidget {
  const _RentalStrip({required this.property});
  final Property property;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 0),
      child: AppCard(
        color: AppColors.tintSurface,
        onTap: () => Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(
            builder: (_) => PropertyDetailScreen(property: property),
          ),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            SizedBox(
              width: 68,
              height: 62,
              child: AppImage(property.image, radius: 12),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    property.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 14.5, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    property.configuration,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.muted),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${rupees(property.monthlyRent)}/mo',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
