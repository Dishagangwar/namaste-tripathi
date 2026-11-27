/// What the app asks a payment provider to charge.
class PaymentRequest {
  const PaymentRequest({
    required this.amount,
    required this.method,
    this.detail = '',
  });

  /// In rupees.
  final double amount;

  /// One of the ids on the payment screen: gpay, paytm, card, netbank, cod.
  final String method;

  /// What the user typed for the method: a UPI id, a card number or a bank.
  final String detail;
}

class PaymentResult {
  const PaymentResult.success(String this.transactionId)
    : success = true,
      failureReason = null;

  const PaymentResult.failure(String this.failureReason)
    : success = false,
      transactionId = null;

  final bool success;
  final String? transactionId;
  final String? failureReason;
}

/// The seam between the checkout UI and whoever actually moves the money.
///
/// Only [MockPaymentGateway] exists. A real provider (Razorpay, Stripe, ...)
/// implements this and is passed to the payment screen in its place; nothing
/// else in the app needs to change.
abstract interface class PaymentGateway {
  Future<PaymentResult> charge(PaymentRequest request);
}

/// Pretends to take a payment. No money moves and nothing leaves the device.
///
/// Outcomes are predictable so every path can be exercised by hand:
///  * a card number ending in `0000` is declined;
///  * a UPI id containing `fail` is declined;
///  * the bank "Server Down Bank" is unavailable;
///  * cash on delivery always succeeds without a charge;
///  * everything else succeeds.
class MockPaymentGateway implements PaymentGateway {
  const MockPaymentGateway({this.delay = const Duration(seconds: 2)});

  /// How long the fake "processing" step takes.
  final Duration delay;

  static const downBank = 'Server Down Bank';

  @override
  Future<PaymentResult> charge(PaymentRequest request) async {
    if (delay > Duration.zero) await Future<void>.delayed(delay);

    final detail = request.detail.trim();
    switch (request.method) {
      case 'card':
        final digits = detail.replaceAll(RegExp(r'\D'), '');
        if (digits.length < 12) {
          return const PaymentResult.failure('Enter a valid card number.');
        }
        if (digits.endsWith('0000')) {
          return const PaymentResult.failure('Your card was declined.');
        }
      case 'gpay':
      case 'paytm':
        if (!detail.contains('@')) {
          return const PaymentResult.failure('Enter a valid UPI ID.');
        }
        if (detail.toLowerCase().contains('fail')) {
          return const PaymentResult.failure(
            'The UPI payment was declined by your bank.',
          );
        }
      case 'netbank':
        if (detail == downBank) {
          return const PaymentResult.failure(
            'That bank is not responding. Try another.',
          );
        }
        if (detail.isEmpty) {
          return const PaymentResult.failure('Choose a bank.');
        }
    }

    final stamp = DateTime.now().microsecondsSinceEpoch;
    return PaymentResult.success(
      request.method == 'cod' ? 'COD-$stamp' : 'MOCK-$stamp',
    );
  }
}
