import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_state.dart';
import '../../core/catalog_state.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/models.dart';
import '../shell/main_shell.dart';
import 'cart_screen.dart';
import 'food_side_screens.dart';

const kFoodNav = <NavSpec>[
  NavSpec('Explore', Icons.explore_outlined, Icons.explore_rounded),
  NavSpec('Orders', Icons.receipt_long_outlined, Icons.receipt_long_rounded),
  NavSpec('Saved', Icons.bookmark_border_rounded, Icons.bookmark_rounded),
  NavSpec('Profile', Icons.person_outline_rounded, Icons.person_rounded),
];

class RestaurantDetailScreen extends StatefulWidget {
  const RestaurantDetailScreen({super.key, required this.restaurant});
  final Restaurant restaurant;

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  late final List<String> _categories = [
    'Popular',
    ...{for (final m in widget.restaurant.menu) m.category}..remove('Popular'),
  ];
  late String _selected = _categories.first;
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<MenuItem> get _items => widget.restaurant.menu
      .where((m) => m.category == _selected)
      .toList();

  List<MenuItem> get _recommended =>
      widget.restaurant.menu.where((m) => m.category != _selected).take(3).toList();

  void _openMenuSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            const Text('Browse the menu',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            for (final c in _categories)
              ListTile(
                title: Text(c,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                trailing: Text(
                  '${widget.restaurant.menu.where((m) => m.category == c).length}',
                  style: const TextStyle(color: AppColors.muted),
                ),
                onTap: () {
                  setState(() => _selected = c);
                  Navigator.pop(context);
                },
              ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.restaurant;
    final cart = context.watch<CartState>();

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Image behind, info card painted on top of it. Keeping both in
              // one sliver is what makes the overlap layer correctly: a
              // SliverAppBar would paint over the card instead.
              SliverToBoxAdapter(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: SizedBox(height: 230, child: AppImage(r.image)),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 204, 16, 0),
                      child: _InfoCard(restaurant: r),
                    ),
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 4,
                      left: 8,
                      child: const _CircleBack(),
                    ),
                  ],
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _ChipsHeader(
                  child: Container(
                    color: AppColors.scaffold,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: FilterChipsRow(
                      items: _categories,
                      selected: _selected,
                      onSelected: (v) => setState(() => _selected = v),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                  child: Text(
                    _selected == 'Popular' ? 'Popular Items' : _selected,
                    style: const TextStyle(
                        fontSize: 19, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              SliverList.builder(
                itemCount: _items.length,
                itemBuilder: (_, i) =>
                    MenuRow(item: _items[i], restaurant: r),
              ),
              if (_recommended.isNotEmpty) ...[
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 20, 16, 10),
                    child: Text(
                      'Recommended',
                      style: TextStyle(
                          fontSize: 19, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                SliverList.builder(
                  itemCount: _recommended.length,
                  itemBuilder: (_, i) =>
                      MenuRow(item: _recommended[i], restaurant: r),
                ),
              ],
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),
          // Floating menu button, as in the recording.
          Positioned(
            bottom: cart.isEmpty ? 24 : 86,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _openMenuSheet,
                child: Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: kLiftShadow,
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.restaurant_rounded,
                          color: Colors.white, size: 19),
                      Text(
                        'Menu',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!cart.isEmpty) const CartBar(),
          ModuleBottomNav(
            index: 0,
            items: kFoodNav,
            onTap: (i) => openFoodTab(context, i),
          ),
        ],
      ),
    );
  }
}

void openFoodTab(BuildContext context, int index) {
  switch (index) {
    case 1:
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const FoodOrdersScreen()),
      );
    case 2:
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const FoodSavedScreen()),
      );
    case 3:
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const FoodProfileScreen()),
      );
    default:
      break;
  }
}

class _CircleBack extends StatelessWidget {
  const _CircleBack();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: GestureDetector(
        onTap: () => Navigator.of(context).maybePop(),
        child: Container(
          width: 42,
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: kSoftShadow,
          ),
          child: const Icon(Icons.arrow_back_rounded,
              size: 21, color: AppColors.text),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.restaurant});
  final Restaurant restaurant;

  @override
  Widget build(BuildContext context) {
    final coupons = context.watch<CatalogState>().coupons;

    return AppCard(
      radius: 22,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  restaurant.name,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w700),
                ),
              ),
              RatingBadge(restaurant.rating, green: true),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            restaurant.cuisine,
            style: const TextStyle(fontSize: 13, color: AppColors.muted),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: IconLabel(
                    Icons.access_time_rounded, restaurant.deliveryTime),
              ),
              Expanded(
                child: IconLabel(
                    Icons.pedal_bike_rounded,
                    restaurant.freeDelivery
                        ? 'Free Delivery'
                        : 'Paid Delivery'),
              ),
              Expanded(
                child: IconLabel(Icons.receipt_long_outlined,
                    'Avg. ${rupees(restaurant.costForTwo)} for two'),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(),
          ),
          const Text(
            'Available Coupons',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 92,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: coupons.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (_, i) {
                final c = coupons[i];
                return Container(
                  width: 172,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.scaffold,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        c.code,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.danger,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        c.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 11.5, color: AppColors.muted),
                      ),
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

class _ChipsHeader extends SliverPersistentHeaderDelegate {
  _ChipsHeader({required this.child});
  final Widget child;

  @override
  double get minExtent => 60;
  @override
  double get maxExtent => 60;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) =>
      SizedBox.expand(child: child);

  @override
  bool shouldRebuild(_ChipsHeader oldDelegate) => oldDelegate.child != child;
}

class MenuRow extends StatelessWidget {
  const MenuRow({super.key, required this.item, required this.restaurant});
  final MenuItem item;
  final Restaurant restaurant;

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartState>();
    final qty = cart.quantityOf(item);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            height: 92,
            child: AppImage(item.image, radius: 14),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _VegMark(isVeg: item.isVeg),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 15.5, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 12.5, color: AppColors.muted, height: 1.4),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      rupees(item.price),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    const Spacer(),
                    if (qty == 0)
                      FilledButton(
                        onPressed: () =>
                            context.read<CartState>().add(item, restaurant),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(84, 38),
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('+ Add',
                            style: TextStyle(fontSize: 13.5)),
                      )
                    else
                      Container(
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _StepButton(
                              icon: Icons.remove_rounded,
                              onTap: () =>
                                  context.read<CartState>().remove(item),
                            ),
                            SizedBox(
                              width: 26,
                              child: Text(
                                '$qty',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            _StepButton(
                              icon: Icons.add_rounded,
                              onTap: () => context
                                  .read<CartState>()
                                  .add(item, restaurant),
                            ),
                          ],
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

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: 32,
        height: 38,
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}

class _VegMark extends StatelessWidget {
  const _VegMark({required this.isVeg});
  final bool isVeg;

  @override
  Widget build(BuildContext context) {
    final color = isVeg ? AppColors.veg : AppColors.nonVeg;
    return Container(
      width: 13,
      height: 13,
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 1.4),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Center(
        child: Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
      ),
    );
  }
}

class CartBar extends StatelessWidget {
  const CartBar({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartState>();
    if (cart.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: GestureDetector(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const CartScreen()),
        ),
        child: Container(
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(28),
            boxShadow: kLiftShadow,
          ),
          child: Row(
            children: [
              Text(
                '${cart.itemCount} ITEM${cart.itemCount == 1 ? '' : 'S'}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                rupees(cart.subtotal),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              const Text(
                'VIEW CART',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.arrow_forward_rounded,
                  color: Colors.white, size: 17),
            ],
          ),
        ),
      ),
    );
  }
}
