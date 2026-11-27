import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/bookings/bookings_bloc.dart';
import '../../bloc/cart/cart_bloc.dart';
import '../../bloc/orders/orders_bloc.dart';
import '../../bloc/session/session_bloc.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/models.dart';
import '../../data/payments.dart';
import 'order_success_screen.dart';

class _Method {
  const _Method(
    this.id,
    this.label,
    this.icon,
    this.section, {
    this.add = false,
  });
  final String id;
  final String label;
  final IconData icon;
  final String section;
  final bool add;
}

const _methods = <_Method>[
  _Method(
    'gpay',
    'Google Pay UPI',
    Icons.account_balance_wallet_outlined,
    'Recommended',
  ),
  _Method('paytm', 'Paytm UPI', Icons.credit_card_rounded, 'Recommended'),
  _Method(
    'card',
    'Add credit or debit cards',
    Icons.credit_card_rounded,
    'Cards',
    add: true,
  ),
  _Method(
    'netbank',
    'Netbanking',
    Icons.account_balance_rounded,
    'Net Banking',
    add: true,
  ),
  _Method(
    'cod',
    'Cash on Delivery',
    Icons.payments_outlined,
    'Pay on Delivery',
    add: true,
  ),
];

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key, this.gateway = const MockPaymentGateway()});

  /// Who takes the payment. A mock by default; see [PaymentGateway].
  final PaymentGateway gateway;

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
                style: const TextStyle(fontSize: 13, color: AppColors.muted),
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
        onAction: () => _pay(context, cart),
      ),
    );
  }

  /// Collects the payment, then places the order only if it went through.
  Future<void> _pay(BuildContext context, CartState cart) async {
    if (cart.isEmpty) {
      showAppSnack(context, 'Your basket is empty.');
      return;
    }
    final method = _methods.firstWhere((m) => m.id == _selected);

    // Cash on delivery has nothing to collect up front.
    PaymentResult? result;
    if (method.id == 'cod') {
      result = await widget.gateway.charge(
        PaymentRequest(amount: cart.total, method: method.id),
      );
    } else {
      result = await showModalBottomSheet<PaymentResult>(
        context: context,
        isScrollControlled: true,
        isDismissible: false,
        enableDrag: false,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.sheet),
          ),
        ),
        builder: (_) => _MockCheckoutSheet(
          method: method,
          amount: cart.total,
          gateway: widget.gateway,
        ),
      );
    }

    if (!context.mounted || result == null) return; // cancelled
    if (!result.success) {
      showAppSnack(context, result.failureReason ?? 'Payment failed.');
      return;
    }
    _placeOrder(context, cart);
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
          subtitle:
              '${order.itemCount} '
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
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                ),
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

/// A stand-in for a provider's checkout: collects one detail for the chosen
/// method, "processes" it through the gateway, and pops with the result.
class _MockCheckoutSheet extends StatefulWidget {
  const _MockCheckoutSheet({
    required this.method,
    required this.amount,
    required this.gateway,
  });

  final _Method method;
  final double amount;
  final PaymentGateway gateway;

  @override
  State<_MockCheckoutSheet> createState() => _MockCheckoutSheetState();
}

class _MockCheckoutSheetState extends State<_MockCheckoutSheet> {
  static const _banks = [
    'State Bank of India',
    'HDFC Bank',
    'ICICI Bank',
    MockPaymentGateway.downBank,
  ];

  late final _controller = TextEditingController(
    text: switch (widget.method.id) {
      'gpay' || 'paytm' => 'demo@upi',
      'card' => '4242 4242 4242 4242',
      _ => '',
    },
  );
  String? _bank;
  bool _processing = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _processing = true;
      _error = null;
    });
    final detail = widget.method.id == 'netbank'
        ? (_bank ?? '')
        : _controller.text;
    final result = await widget.gateway.charge(
      PaymentRequest(
        amount: widget.amount,
        method: widget.method.id,
        detail: detail,
      ),
    );
    if (!mounted) return;
    if (result.success) {
      Navigator.pop(context, result);
    } else {
      // Keep the sheet open so the user can correct the detail and retry.
      setState(() {
        _processing = false;
        _error = result.failureReason;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final id = widget.method.id;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.method.label,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Test mode: no real money is charged.',
                style: TextStyle(fontSize: 12.5, color: AppColors.muted),
              ),
              const SizedBox(height: 16),
              if (id == 'netbank')
                DropdownButtonFormField<String>(
                  initialValue: _bank,
                  decoration: const InputDecoration(labelText: 'Bank'),
                  items: [
                    for (final b in _banks)
                      DropdownMenuItem(value: b, child: Text(b)),
                  ],
                  onChanged: _processing
                      ? null
                      : (v) => setState(() => _bank = v),
                )
              else
                TextField(
                  controller: _controller,
                  enabled: !_processing,
                  keyboardType: id == 'card'
                      ? TextInputType.number
                      : TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: id == 'card' ? 'Card number' : 'UPI ID',
                    helperText: id == 'card'
                        ? 'Ending 0000 is declined'
                        : 'An ID containing "fail" is declined',
                  ),
                ),
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(
                  _error!,
                  style: const TextStyle(fontSize: 13, color: AppColors.danger),
                ),
              ],
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _processing ? null : _submit,
                  child: _processing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text('Pay ${rupees(widget.amount)}'),
                ),
              ),
              if (!_processing)
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
