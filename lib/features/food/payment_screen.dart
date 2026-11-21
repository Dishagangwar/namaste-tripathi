import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/bookings/bookings_bloc.dart';
import '../../bloc/cart/cart_bloc.dart';
import '../../bloc/orders/orders_bloc.dart';
import '../../bloc/session/session_bloc.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/models.dart';
import 'order_success_screen.dart';

class _Method {
  const _Method(this.id, this.label, this.icon, this.section, {this.add = false});
  final String id;
  final String label;
  final IconData icon;
  final String section;
  final bool add;
}

const _methods = <_Method>[
  _Method('gpay', 'Google Pay UPI', Icons.account_balance_wallet_outlined,
      'Recommended'),
  _Method('paytm', 'Paytm UPI', Icons.credit_card_rounded, 'Recommended'),
  _Method('card', 'Add credit or debit cards', Icons.credit_card_rounded,
      'Cards', add: true),
  _Method('netbank', 'Netbanking', Icons.account_balance_rounded,
      'Net Banking', add: true),
  _Method('cod', 'Cash on Delivery', Icons.payments_outlined,
      'Pay on Delivery', add: true),
];

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selected = 'gpay';

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartBloc>().state;
    final sections = <String>[];
    for (final m in _methods) {
      if (!sections.contains(m.section)) sections.add(m.section);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Payment Method')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
        children: [
          for (final section in sections) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 14, 4, 10),
              child: Text(
                section,
                style: const TextStyle(
                    fontSize: 13, color: AppColors.muted),
              ),
            ),
            for (final m in _methods.where((m) => m.section == section))
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _MethodTile(
                  method: m,
                  selected: _selected == m.id,
                  onTap: () => setState(() => _selected = m.id),
                ),
              ),
          ],
        ],
      ),
      bottomNavigationBar: BottomActionBar(
        caption: 'Total amount',
        value: rupees(cart.total),
        actionLabel: 'Place Order',
        onAction: () => _placeOrder(context, cart),
      ),
    );
  }

  /// Turns the basket into an order, sends it, and leaves for the tracker.
  ///
  /// The order is built before the cart is cleared, and the success screen is
  /// pushed with it rather than reading the cart back -- by the time that
  /// screen builds, the basket is empty.
  void _placeOrder(BuildContext context, CartState cart) {
    // The backend rejects an empty order, and rightly so; say why rather
    // than letting the request fail silently.
    if (cart.isEmpty) {
      showAppSnack(context, 'Your basket is empty.');
      return;
    }

    final now = DateTime.now();
    final order = FoodOrder(
      // A local id so the optimistic copy can be found and replaced by the
      // stored row, which arrives with the server's own id and reference.
      id: 'local-${now.microsecondsSinceEpoch}',
      restaurantId: cart.restaurant?.id ?? '',
      restaurantName: cart.restaurant?.name ?? 'your restaurant',
      image: cart.restaurant?.image ?? '',
      lines: [
        for (final line in cart.lines)
          OrderLine(
            itemId: line.item.id,
            name: line.item.name,
            quantity: line.quantity,
            price: line.item.price,
          ),
      ],
      subtotal: cart.subtotal,
      deliveryFee: cart.deliveryFee,
      taxes: cart.taxes,
      discount: cart.discount,
      total: cart.total,
      paymentMethod: _selected,
      couponCode: cart.coupon?.code,
      instructions: cart.instructions.toList(),
      placedAt: now,
    );

    context.read<OrdersBloc>().add(OrderPlaced(order));

    // The order is also an itinerary entry, so it turns up on the bookings
    // screen next to stays and visits rather than only in order history.
    context.read<BookingsBloc>().add(
          BookingAdded(
            Booking(
              id: 'order-${now.microsecondsSinceEpoch}',
              title: order.restaurantName,
              subtitle: '${order.itemCount} '
                  '${order.itemCount == 1 ? 'item' : 'items'} • '
                  '${rupees(order.total)}',
              kind: 'Food Order',
              when: formatWhen(now),
              status: BookingStatus.processing,
              image: order.image,
              location: context.read<SessionBloc>().state.address,
            ),
          ),
        );

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => OrderSuccessScreen(order: order)),
    );
    context.read<CartBloc>().add(const CartCleared());
  }
}

class _MethodTile extends StatelessWidget {
  const _MethodTile({
    required this.method,
    required this.selected,
    required this.onTap,
  });

  final _Method method;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 1.6 : 1,
          ),
          boxShadow: selected ? kSoftShadow : null,
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFF8F2E0),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(method.icon, size: 20, color: AppColors.text),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                method.label,
                style: const TextStyle(
                    fontSize: 14.5, fontWeight: FontWeight.w600),
              ),
            ),
            if (method.add)
              const Text(
                'ADD',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.success,
                ),
              )
            else
              const Icon(Icons.chevron_right_rounded, color: AppColors.faint),
          ],
        ),
      ),
    );
  }
}
