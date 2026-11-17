import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/catalog_state.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/mock_data.dart';
import '../../data/models.dart';
import '../shell/services_tab.dart';
import 'hotel_detail_screen.dart';

class HotelsListScreen extends StatefulWidget {
  const HotelsListScreen({super.key, required this.onBack});
  final VoidCallback onBack;

  @override
  State<HotelsListScreen> createState() => _HotelsListScreenState();
}

class _HotelsListScreenState extends State<HotelsListScreen> {
  String _filter = 'All';
  String _query = '';

  List<Hotel> _resultsFrom(List<Hotel> hotels) => hotels
      .where((h) => _filter == 'All' || h.category == _filter)
      .where((h) =>
          _query.isEmpty ||
          h.name.toLowerCase().contains(_query.toLowerCase()) ||
          h.location.toLowerCase().contains(_query.toLowerCase()))
      .toList();

  @override
  Widget build(BuildContext context) {
    final results = _resultsFrom(context.watch<CatalogState>().hotels);

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          ModuleHeader(
            title: 'Hotels & Stays',
            onBack: widget.onBack,
            trailing: IconButton(
              onPressed: () =>
                  showAppSnack(context, 'Map view is not wired up yet.'),
              icon: const Icon(Icons.map_outlined, color: AppColors.primary),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: AppSearchField(
              hint: 'Search for location, hotel...',
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          FilterChipsRow(
            items: kHotelFilters,
            selected: _filter,
            onSelected: (v) => setState(() => _filter = v),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: results.length,
              separatorBuilder: (_, _) => const SizedBox(height: 16),
              itemBuilder: (_, i) => HotelCard(hotel: results[i]),
            ),
          ),
        ],
      ),
    );
  }
}

class HotelCard extends StatelessWidget {
  const HotelCard({super.key, required this.hotel});
  final Hotel hotel;

  @override
  Widget build(BuildContext context) {
    return AppCard(
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
                height: 190,
                width: double.infinity,
                child: AppImage(hotel.image),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: RatingBadge(hotel.rating, onDark: true),
              ),
              Positioned(
                bottom: 12,
                left: 12,
                child: OverlayTag(hotel.category),
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
                        hotel.name,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          rupees(hotel.pricePerNight),
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                        const Text(
                          'per night',
                          style: TextStyle(
                              fontSize: 11, color: AppColors.muted),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                IconLabel(
                  Icons.location_on_rounded,
                  '${hotel.location} • ${hotel.distance}',
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final a in hotel.amenities)
                      Pill(a,
                          bg: const Color(0xFFF9F3E3),
                          fg: AppColors.muted,
                          bold: false),
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
