import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_state.dart';
import '../../core/catalog_state.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/mock_data.dart';
import '../../data/models.dart';
import '../shell/main_shell.dart';
import 'property_detail_screen.dart';
import 'schedule_visit_screen.dart';

const kRealEstateNav = <NavSpec>[
  NavSpec('Explore', Icons.explore_outlined, Icons.explore_rounded),
  NavSpec('Favorites', Icons.favorite_border_rounded, Icons.favorite_rounded),
  NavSpec('Schedule', Icons.event_available_outlined,
      Icons.event_available_rounded),
  NavSpec('Profile', Icons.person_outline_rounded, Icons.person_rounded),
];

class RealEstateShell extends StatefulWidget {
  const RealEstateShell({super.key, this.initialIndex = 0});
  final int initialIndex;

  @override
  State<RealEstateShell> createState() => _RealEstateShellState();
}

class _RealEstateShellState extends State<RealEstateShell> {
  late int _index = widget.initialIndex;

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogState>();
    // The Schedule tab opens on a showcase listing; whichever listing the
    // catalogue puts first stands in when `pr5` is not there.
    final showcase = catalog.propertyById('pr5') ??
        (catalog.properties.isNotEmpty ? catalog.properties.first : null);

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          const _ExploreTab(),
          const _FavouritesTab(),
          if (showcase != null)
            ScheduleVisitScreen(property: showcase, embedded: true)
          else
            const Center(
              child: Text('No listings yet.',
                  style: TextStyle(color: AppColors.muted)),
            ),
          const _ReProfileTab(),
        ],
      ),
      bottomNavigationBar: ModuleBottomNav(
        index: _index,
        items: kRealEstateNav,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}

class _ExploreTab extends StatefulWidget {
  const _ExploreTab();

  @override
  State<_ExploreTab> createState() => _ExploreTabState();
}

class _ExploreTabState extends State<_ExploreTab> {
  String _filter = 'All';
  String _query = '';

  List<Property> _resultsFrom(List<Property> properties) => properties
      .where((p) => _filter == 'All' || p.tags.contains(_filter))
      .where((p) =>
          _query.isEmpty ||
          p.name.toLowerCase().contains(_query.toLowerCase()) ||
          p.location.toLowerCase().contains(_query.toLowerCase()))
      .toList();

  @override
  Widget build(BuildContext context) {
    final results = _resultsFrom(context.watch<CatalogState>().properties);

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 12, 6),
            child: Row(
              children: [
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Explore',
                    style: TextStyle(
                        fontSize: 25, fontWeight: FontWeight.w800),
                  ),
                ),
                IconButton(
                  onPressed: () => showAppSnack(
                      context, 'Try the search box below.'),
                  icon: const Icon(Icons.search_rounded, size: 26),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: AppSearchField(
              hint: 'Search by name or location...',
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          FilterChipsRow(
            items: kPropertyFilters,
            selected: _filter,
            onSelected: (v) => setState(() => _filter = v),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: results.length,
              separatorBuilder: (_, _) => const SizedBox(height: 16),
              itemBuilder: (_, i) => PropertyCard(property: results[i]),
            ),
          ),
        ],
      ),
    );
  }
}

class PropertyCard extends StatelessWidget {
  const PropertyCard({super.key, required this.property});
  final Property property;

  @override
  Widget build(BuildContext context) {
    final favs = context.watch<FavouritesState>();
    final liked = favs.isPropertyFavourite(property.id);

    return AppCard(
      padding: EdgeInsets.zero,
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PropertyDetailScreen(property: property),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              SizedBox(
                height: 190,
                width: double.infinity,
                child: AppImage(property.image),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: GestureDetector(
                  onTap: () =>
                      context.read<FavouritesState>().toggleProperty(property.id),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      liked
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      size: 20,
                      color: liked ? AppColors.primary : AppColors.muted,
                    ),
                  ),
                ),
              ),
              if (property.tags.contains('Premium'))
                const Positioned(
                  top: 12,
                  left: 12,
                  child: OverlayTag('Premium'),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        property.name,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            height: 1.25),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          property.forRent
                              ? '${rupees(property.monthlyRent)}/mo'
                              : rupees(property.price),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          property.forRent ? 'PER MONTH' : 'ESTIMATED PRICE',
                          style: const TextStyle(
                            fontSize: 8.5,
                            letterSpacing: 0.6,
                            fontWeight: FontWeight.w600,
                            color: AppColors.faint,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                IconLabel(Icons.location_on_rounded, property.location),
                const SizedBox(height: 16),
                Row(
                  children: [
                    IconLabel(Icons.bed_rounded, '${property.beds}'),
                    const SizedBox(width: 18),
                    IconLabel(Icons.bathtub_rounded, '${property.baths}'),
                    const SizedBox(width: 18),
                    IconLabel(
                        Icons.square_foot_rounded, '${property.area}'),
                    const Spacer(),
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.arrow_forward_rounded,
                          color: Colors.white, size: 20),
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
}

class _FavouritesTab extends StatelessWidget {
  const _FavouritesTab();

  @override
  Widget build(BuildContext context) {
    final favs = context.watch<FavouritesState>();
    final saved = context
        .watch<CatalogState>()
        .properties
        .where((p) => favs.isPropertyFavourite(p.id))
        .toList();

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Text(
              'Favourites',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ),
          Expanded(
            child: saved.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.favorite_border_rounded,
                            size: 48, color: AppColors.faint),
                        SizedBox(height: 12),
                        Text('Nothing saved yet.',
                            style: TextStyle(color: AppColors.muted)),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    itemCount: saved.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 16),
                    itemBuilder: (_, i) =>
                        _FavouriteCard(property: saved[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

class _FavouriteCard extends StatelessWidget {
  const _FavouriteCard({required this.property});
  final Property property;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              SizedBox(
                height: 160,
                width: double.infinity,
                child: AppImage(property.image),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    property.forRent
                        ? '${rupees(property.monthlyRent)}/mo'
                        : rupees(property.price),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.favorite_rounded,
                      size: 20, color: AppColors.primary),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  property.name,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                IconLabel(Icons.location_on_rounded, property.location),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                PropertyDetailScreen(property: property),
                          ),
                        ),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(46),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('View Details'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => context
                          .read<FavouritesState>()
                          .toggleProperty(property.id),
                      child: Container(
                        width: 50,
                        height: 46,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F2F6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.delete_outline_rounded,
                            size: 21, color: AppColors.muted),
                      ),
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
}

class _ReProfileTab extends StatelessWidget {
  const _ReProfileTab();

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionState>();
    final favs = context.watch<FavouritesState>();

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
        children: [
          const Text(
            'Your Property Profile',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 18),
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
                      Text(session.name,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 3),
                      Text(
                        '${favs.propertyIds.length} saved • 1 visit booked',
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          for (final row in const [
            (Icons.gavel_rounded, 'Offers you have made'),
            (Icons.description_outlined, 'Documents'),
            (Icons.calculate_outlined, 'Mortgage calculator'),
            (Icons.notifications_none_rounded, 'Alert preferences'),
          ])
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AppCard(
                onTap: () => showAppSnack(context, '${row.$2} coming soon.'),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Icon(row.$1, size: 21, color: AppColors.primary),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(row.$2,
                          style: const TextStyle(
                              fontSize: 14.5, fontWeight: FontWeight.w600)),
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
