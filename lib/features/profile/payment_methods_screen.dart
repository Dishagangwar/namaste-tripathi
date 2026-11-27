import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/preferences/preferences_cubit.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';

class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({super.key});

  Future<void> _add(BuildContext context, PaymentKind kind) async {
    final cubit = context.read<PreferencesCubit>();
    final value = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
      ),
      builder: (_) => _AddPaymentSheet(kind: kind),
    );
    if (value == null) return;
    kind == PaymentKind.card ? cubit.addCard(value) : cubit.addUpi(value);
  }

  @override
  Widget build(BuildContext context) {
    final payments = context.watch<PreferencesCubit>().state.payments;

    return Scaffold(
      appBar: AppBar(title: const Text('Payment methods')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          if (payments.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Text('No saved payment methods yet.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.muted)),
            ),
          for (final p in payments) ...[
            AppCard(
              child: Row(
                children: [
                  SoftIconBox(
                      p.kind == PaymentKind.card
                          ? Icons.credit_card_rounded
                          : Icons.account_balance_wallet_outlined,
                      size: 42,
                      iconSize: 20),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.title,
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text(p.detail,
                            style: const TextStyle(
                                fontSize: 13, color: AppColors.muted)),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Remove',
                    icon: const Icon(Icons.delete_outline_rounded,
                        size: 20, color: AppColors.danger),
                    onPressed: () =>
                        context.read<PreferencesCubit>().removePayment(p.id),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => _add(context, PaymentKind.upi),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add UPI ID'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => _add(context, PaymentKind.card),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add card'),
          ),
        ],
      ),
    );
  }
}

/// Owns its controller so it is disposed with the sheet, after it has
/// finished closing.
class _AddPaymentSheet extends StatefulWidget {
  const _AddPaymentSheet({required this.kind});
  final PaymentKind kind;

  @override
  State<_AddPaymentSheet> createState() => _AddPaymentSheetState();
}

class _AddPaymentSheetState extends State<_AddPaymentSheet> {
  final _formKey = GlobalKey<FormState>();
  final _field = TextEditingController();

  bool get _isCard => widget.kind == PaymentKind.card;

  @override
  void dispose() {
    _field.dispose();
    super.dispose();
  }

  String? _validate(String? v) {
    final value = (v ?? '').trim();
    if (_isCard) {
      final digits = value.replaceAll(RegExp(r'\D'), '');
      return digits.length < 12 || digits.length > 19
          ? 'Enter a valid card number'
          : null;
    }
    return RegExp(r'^[\w.\-]{2,}@[a-zA-Z]{2,}$').hasMatch(value)
        ? null
        : 'Enter a valid UPI ID';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_isCard ? 'Add a card' : 'Add a UPI ID',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w700)),
                if (_isCard) ...[
                  const SizedBox(height: 4),
                  const Text('Only the last 4 digits are kept on this device.',
                      style:
                          TextStyle(fontSize: 12.5, color: AppColors.muted)),
                ],
                const SizedBox(height: 16),
                TextFormField(
                  controller: _field,
                  autofocus: true,
                  keyboardType: _isCard
                      ? TextInputType.number
                      : TextInputType.emailAddress,
                  decoration: InputDecoration(
                      labelText: _isCard ? 'Card number' : 'UPI ID',
                      hintText: _isCard ? null : 'name@bank'),
                  validator: _validate,
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        Navigator.pop(context, _field.text);
                      }
                    },
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
