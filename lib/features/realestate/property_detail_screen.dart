import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/favourites/favourites_bloc.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/models.dart';
import 'schedule_visit_screen.dart';

class PropertyDetailScreen extends StatelessWidget {
  const PropertyDetailScreen({super.key, required this.property});
  final Property property;

  @override
  Widget build(BuildContext context) {
    final favs = context.watch<FavouritesBloc>().state;
    final liked = favs.isPropertyFavourite(property.id);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 290,
            pinned: true,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: GestureDetector(
                onTap: () => Navigator.of(context).maybePop(),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: kSoftShadow,
                  ),
                  child: const Icon(Icons.arrow_back_rounded,
                      size: 21, color: AppColors.text),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: GestureDetector(
                  onTap: () => context.read<FavouritesBloc>().add(FavouritePropertyToggled(property.id)),
                  child: Container(
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: kSoftShadow,
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
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: PageView(
                children: [
                  for (final g in property.gallery) AppImage(g),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
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
                              fontSize: 25,
                              fontWeight: FontWeight.w800,
                              height: 1.2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            property.forRent
                                ? '${rupees(property.monthlyRent)}/mo'
                                : rupees(property.price),
                            style: const TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                          const Text(
                            'ESTIMATED PRICE',
                            style: TextStyle(
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
                  const SizedBox(height: 10),
                  IconLabel(Icons.location_on_rounded, property.location),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final t in property.tags.where((t) => t != 'All'))
                        Pill(t.toUpperCase()),
                    ],
                  ),
                  const SizedBox(height: 20),
                  AppCard(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    child: Row(
                      children: [
                        Expanded(
                            child: _Stat(Icons.bed_rounded, '${property.beds}',
                                'Bedrooms')),
                        Expanded(
                            child: _Stat(Icons.bathtub_rounded,
                                '${property.baths}', 'Bathrooms')),
                        Expanded(
                            child: _Stat(Icons.square_foot_rounded,
                                '${property.area}', 'Sq ft')),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text('About this property',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  Text(
                    property.description,
                    style: const TextStyle(
                        fontSize: 14, color: AppColors.muted, height: 1.7),
                  ),
                  const SizedBox(height: 22),
                  const Text('Gallery',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 100,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: property.gallery.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 12),
                      itemBuilder: (_, i) => SizedBox(
                        width: 140,
                        child: AppImage(property.gallery[i], radius: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomActionBar(
        caption: property.forRent ? 'Per month' : 'Estimated price',
        value: property.forRent
            ? rupees(property.monthlyRent)
            : rupees(property.price),
        actionLabel: 'Schedule Visit',
        trailingIcon: Icons.event_available_rounded,
        onAction: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ScheduleVisitScreen(property: property),
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.icon, this.value, this.label);
  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 22, color: AppColors.primary),
        const SizedBox(height: 8),
        Text(value,
            style:
                const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(fontSize: 11.5, color: AppColors.muted)),
      ],
    );
  }
}
