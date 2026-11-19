import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/cart/cart_bloc.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
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
        onAction: () {
          final total = cart.total;
          final restaurantName = cart.restaurant?.name ?? 'your restaurant';
          final image = cart.restaurant?.image ?? '';
          final lines = cart.lines
              .map((l) => '${l.quantity} × ${l.item.name}')
              .toList();
          final subtotal = cart.subtotal;
          final fee = cart.deliveryFee;
          final tax = cart.taxes;
          final discount = cart.discount;
          final code = cart.coupon?.code;

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => OrderSuccessScreen(
                restaurantName: restaurantName,
                image: image,
                lines: lines,
                subtotal: subtotal,
                deliveryFee: fee,
                taxes: tax,
                discount: discount,
                couponCode: code,
                total: total,
              ),
            ),
          );
          context.read<CartBloc>().add(const CartCleared());
        },
      ),
    );
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
