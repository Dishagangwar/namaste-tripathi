import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_state.dart';
import '../../core/catalog_state.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/models.dart';
import 'payment_screen.dart';

const _instructions = <(IconData, String)>[
  (Icons.pets_rounded, 'Pet at Home'),
  (Icons.phone_disabled_rounded, 'Avoid Calling'),
  (Icons.notifications_off_rounded, "Don't ring the bell"),
];

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartState>();
    final coupons = context.watch<CatalogState>().coupons;

    if (cart.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Cart')),
        body: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.shopping_bag_outlined,
                  size: 52, color: AppColors.faint),
              SizedBox(height: 14),
              Text('Your cart is empty.',
                  style: TextStyle(color: AppColors.muted)),
            ],
          ),
        ),
      );
    }

    final suggestions = cart.restaurant!.menu
        .where((m) => cart.quantityOf(m) == 0)
        .take(4)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('My Cart')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          AppCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 44,
                      height: 44,
                      child: AppImage(cart.restaurant!.image, radius: 10),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        cart.restaurant!.name,
                        style: const TextStyle(
                            fontSize: 15.5, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(),
                ),
                for (final line in cart.lines) _CartLineRow(line: line),
              ],
            ),
          ),
          if (suggestions.isNotEmpty) ...[
            const SizedBox(height: 22),
            const Text('Add more items',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            SizedBox(
              height: 136,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: suggestions.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (_, i) =>
                    _SuggestionCard(item: suggestions[i], cart: cart),
              ),
            ),
          ],
          const SizedBox(height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Available Coupons',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary)),
              GestureDetector(
                onTap: () => showAppSnack(context, 'Showing all coupons.'),
                child: const Text('View All',
                    style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryLight)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 112,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: coupons.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (_, i) =>
                  _CouponCard(coupon: coupons[i], cart: cart),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Bill Details',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          AppCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _BillRow('Item Total', rupees(cart.subtotal)),
                const SizedBox(height: 10),
                _BillRow(
                  'Delivery Fee',
                  cart.deliveryFee == 0 ? 'FREE' : rupees(cart.deliveryFee),
                  valueColor:
                      cart.deliveryFee == 0 ? AppColors.success : null,
                ),
                const SizedBox(height: 10),
                _BillRow('Taxes & Charges', rupees(cart.taxes)),
                if (cart.discount > 0) ...[
                  const SizedBox(height: 10),
                  _BillRow(
                    'Coupon Discount (${cart.coupon!.code})',
                    '-${rupees(cart.discount)}',
                    labelColor: AppColors.success,
                    valueColor: AppColors.success,
                  ),
                ],
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Divider(),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total',
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w700)),
                    Text(
                      rupees(cart.total),
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Instructions for Partner',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Row(
            children: [
              for (final ins in _instructions) ...[
                Expanded(
                  child: _InstructionTile(
                    icon: ins.$1,
                    label: ins.$2,
                    selected: cart.instructions.contains(ins.$2),
                    onTap: () =>
                        context.read<CartState>().toggleInstruction(ins.$2),
                  ),
                ),
                if (ins != _instructions.last) const SizedBox(width: 10),
              ],
            ],
          ),
        ],
      ),
      bottomNavigationBar: BottomActionBar(
        caption: 'Total amount',
        value: rupees(cart.total),
        actionLabel: 'Place Order',
        onAction: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const PaymentScreen()),
        ),
      ),
    );
  }
}

class _CartLineRow extends StatelessWidget {
  const _CartLineRow({required this.line});
  final CartLine line;

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartState>();
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          SizedBox(
            width: 52,
            height: 52,
            child: AppImage(line.item.image, radius: 10),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  line.item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 14.5, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 3),
                Text(
                  rupees(line.item.price),
                  style:
                      const TextStyle(fontSize: 13, color: AppColors.muted),
                ),
              ],
            ),
          ),
          Container(
            height: 34,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: AppColors.primary),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () => cart.remove(line.item),
                  child: const SizedBox(
                    width: 30,
                    height: 34,
                    child: Icon(Icons.remove_rounded,
                        size: 16, color: AppColors.primary),
                  ),
                ),
                SizedBox(
                  width: 22,
                  child: Text(
                    '${line.quantity}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                        color: AppColors.primary),
                  ),
                ),
                InkWell(
                  onTap: () => cart.add(line.item, cart.restaurant!),
                  child: const SizedBox(
                    width: 30,
                    height: 34,
                    child: Icon(Icons.add_rounded,
                        size: 16, color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 64,
            child: Text(
              rupees(line.total),
              textAlign: TextAlign.right,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard({required this.item, required this.cart});
  final MenuItem item;
  final CartState cart;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 112,
      child: AppCard(
        padding: const EdgeInsets.all(8),
        onTap: () => context.read<CartState>().add(item, cart.restaurant!),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 58,
              width: double.infinity,
              child: AppImage(item.image, radius: 9),
            ),
            const SizedBox(height: 7),
            Text(
              item.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 3),
            Text(
              rupees(item.price),
              style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}

class _CouponCard extends StatelessWidget {
  const _CouponCard({required this.coupon, required this.cart});
  final Coupon coupon;
  final CartState cart;

  @override
  Widget build(BuildContext context) {
    final applied = cart.coupon?.code == coupon.code;
    final eligible = cart.subtotal >= coupon.minOrder;

    return Container(
      width: 190,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: applied ? const Color(0xFFF1FBF4) : Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: applied ? AppColors.success : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  coupon.code,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: applied ? AppColors.success : AppColors.text,
                  ),
                ),
              ),
              if (applied)
                const Icon(Icons.check_circle_rounded,
                    size: 18, color: AppColors.success),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            coupon.description.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10.5, color: AppColors.muted),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 32,
            child: applied
                ? Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.successBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '✓ Applied',
                      style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.success),
                    ),
                  )
                : FilledButton(
                    onPressed: eligible
                        ? () => context.read<CartState>().applyCoupon(coupon)
                        : () => showAppSnack(
                              context,
                              'Add ${rupees(coupon.minOrder - cart.subtotal)} '
                              'more to use ${coupon.code}.',
                            ),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(32),
                      padding: EdgeInsets.zero,
                      backgroundColor: eligible
                          ? AppColors.primary
                          : AppColors.primary.withValues(alpha: 0.35),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Apply',
                        style: TextStyle(fontSize: 13)),
                  ),
          ),
        ],
      ),
    );
  }
}

class _BillRow extends StatelessWidget {
  const _BillRow(this.label, this.value, {this.labelColor, this.valueColor});
  final String label;
  final String value;
  final Color? labelColor;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            style: TextStyle(
                fontSize: 13.5, color: labelColor ?? AppColors.muted),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.text,
          ),
        ),
      ],
    );
  }
}

class _InstructionTile extends StatelessWidget {
  const _InstructionTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 92,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: selected ? AppColors.tintSurface : const Color(0xFFF8F2E0),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.primary : Colors.transparent,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 20,
                color: selected ? AppColors.primary : AppColors.muted),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                height: 1.3,
                fontWeight: FontWeight.w500,
                color: selected ? AppColors.primary : AppColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
