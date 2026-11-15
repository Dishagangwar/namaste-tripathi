import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/mock_data.dart';
import '../../data/models.dart';
import '../shell/services_tab.dart';
import 'restaurant_detail_screen.dart';

class FoodListScreen extends StatefulWidget {
  const FoodListScreen({super.key, required this.onBack});
  final VoidCallback onBack;

  @override
  State<FoodListScreen> createState() => _FoodListScreenState();
}

class _FoodListScreenState extends State<FoodListScreen> {
  String _filter = 'All';
  String _query = '';
  bool _sortByRating = false;

  List<Restaurant> get _results {
    var list = kRestaurants
        .where((r) => _filter == 'All' || r.tags.contains(_filter))
        .where((r) =>
            _query.isEmpty ||
            r.name.toLowerCase().contains(_query.toLowerCase()) ||
            r.cuisine.toLowerCase().contains(_query.toLowerCase()))
        .toList();
    if (_sortByRating) {
      list.sort((a, b) => b.rating.compareTo(a.rating));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final results = _results;

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          ModuleHeader(
            title: 'Food Delivery',
            onBack: widget.onBack,
            centerTitle: false,
            trailing: IconButton(
              onPressed: () => setState(() => _sortByRating = !_sortByRating),
              icon: Icon(
                Icons.tune_rounded,
                color: _sortByRating ? AppColors.primary : AppColors.muted,
              ),
              tooltip: 'Top rated first',
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: AppSearchField(
              hint: 'Search restaurants, cuisines...',
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          FilterChipsRow(
            items: kCuisineFilters,
            selected: _filter,
            onSelected: (v) => setState(() => _filter = v),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: results.isEmpty
                ? const _EmptyResults()
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: results.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 16),
                    itemBuilder: (_, i) =>
                        RestaurantCard(restaurant: results[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

class _EmptyResults extends StatelessWidget {
  const _EmptyResults();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off_rounded, size: 46, color: AppColors.faint),
          SizedBox(height: 12),
          Text(
            'Nothing matches that yet.',
            style: TextStyle(color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

class RestaurantCard extends StatelessWidget {
  const RestaurantCard({super.key, required this.restaurant});
  final Restaurant restaurant;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      onTap: () => Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          builder: (_) => RestaurantDetailScreen(restaurant: restaurant),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              SizedBox(
                height: 170,
                width: double.infinity,
                child: AppImage(restaurant.image),
              ),
              if (restaurant.badge != null)
                Positioned(
                  top: 12,
                  left: 12,
                  child: OverlayTag(
                    restaurant.badge!,
                    color: AppColors.primary,
                  ),
                ),
              Positioned(
                top: 12,
                right: 12,
                child: RatingBadge(restaurant.rating, onDark: true),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        restaurant.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      restaurant.deliveryTime,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  restaurant.cuisine,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, color: AppColors.muted),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(),
                ),
                Row(
                  children: [
                    IconLabel(
                      Icons.pedal_bike_rounded,
                      restaurant.freeDelivery ? 'Free Delivery' : 'Paid Delivery',
                    ),
                    const SizedBox(width: 18),
                    IconLabel(
                      Icons.receipt_long_outlined,
                      'Avg. ${rupees(restaurant.costForTwo)} for two',
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
