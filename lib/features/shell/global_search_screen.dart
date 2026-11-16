import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/catalog_state.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../food/restaurant_detail_screen.dart';
import '../hotels/hotel_detail_screen.dart';
import '../providers/provider_detail_screen.dart';
import '../realestate/property_detail_screen.dart';
import 'services_tab.dart';

class _Hit {
  const _Hit(this.title, this.subtitle, this.image, this.kind, this.open);
  final String title;
  final String subtitle;
  final String image;
  final String kind;
  final void Function(BuildContext) open;
}

class GlobalSearchScreen extends StatefulWidget {
  const GlobalSearchScreen({super.key, required this.onBack});
  final VoidCallback onBack;

  @override
  State<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends State<GlobalSearchScreen> {
  String _query = '';

  List<_Hit> _allFrom(CatalogState catalog) => [
        for (final r in catalog.restaurants)
          _Hit(
            r.name,
            r.cuisine,
            r.image,
            'Restaurant',
            (c) => Navigator.of(c, rootNavigator: true).push(
              MaterialPageRoute(
                builder: (_) => RestaurantDetailScreen(restaurant: r),
              ),
            ),
          ),
        for (final h in catalog.hotels)
          _Hit(
            h.name,
            '${h.category} • ${h.location}',
            h.image,
            'Hotel',
            (c) => Navigator.of(c, rootNavigator: true).push(
              MaterialPageRoute(builder: (_) => HotelDetailScreen(hotel: h)),
            ),
          ),
        for (final p in catalog.properties)
          _Hit(
            p.name,
            p.location,
            p.image,
            'Property',
            (c) => Navigator.of(c, rootNavigator: true).push(
              MaterialPageRoute(
                builder: (_) => PropertyDetailScreen(property: p),
              ),
            ),
          ),
        for (final s in catalog.providers)
          _Hit(
            s.name,
            s.profession,
            s.photo,
            'Professional',
            (c) => Navigator.of(c, rootNavigator: true).push(
              MaterialPageRoute(builder: (_) => ProviderDetailScreen(pro: s)),
            ),
          ),
      ];

  List<_Hit> _resultsFrom(CatalogState catalog) {
    if (_query.trim().isEmpty) return const [];
    final q = _query.toLowerCase();
    return _allFrom(catalog)
        .where((h) =>
            h.title.toLowerCase().contains(q) ||
            h.subtitle.toLowerCase().contains(q) ||
            h.kind.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final results = _resultsFrom(context.watch<CatalogState>());

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          ModuleHeader(title: 'Search', onBack: widget.onBack),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: AppSearchField(
              hint: 'Search for food, hotels, or rides',
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Expanded(
            child: _query.trim().isEmpty
                ? _Suggestions(
                    onPick: (v) => setState(() => _query = v),
                  )
                : results.isEmpty
                    ? const Center(
                        child: Text('Nothing matched that.',
                            style: TextStyle(color: AppColors.muted)),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        itemCount: results.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: 12),
                        itemBuilder: (_, i) {
                          final hit = results[i];
                          return AppCard(
                            padding: const EdgeInsets.all(12),
                            onTap: () => hit.open(context),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 56,
                                  height: 56,
                                  child: AppImage(hit.image, radius: 12),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        hit.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        hit.subtitle,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontSize: 12.5,
                                            color: AppColors.muted),
                                      ),
                                    ],
                                  ),
                                ),
                                Pill(hit.kind),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _Suggestions extends StatelessWidget {
  const _Suggestions({required this.onPick});
  final ValueChanged<String> onPick;

  static const _terms = [
    'Biryani',
    'Luxury',
    'Electrician',
    'Villa',
    'Italian',
    'Spa',
    'Plumber',
    'Resort',
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      children: [
        const Text(
          'Trending searches',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final t in _terms)
              GestureDetector(
                onTap: () => onPick(t),
                child: Pill(t, icon: Icons.trending_up_rounded),
              ),
          ],
        ),
      ],
    );
  }
}
