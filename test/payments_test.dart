import 'package:flutter_test/flutter_test.dart';
import 'package:namaste_tripathi/data/payments.dart';

void main() {
  const gateway = MockPaymentGateway(delay: Duration.zero);

  Future<PaymentResult> pay(String method, [String detail = '']) => gateway
      .charge(PaymentRequest(amount: 250, method: method, detail: detail));

  test('a normal UPI id, card and bank all succeed', () async {
    expect((await pay('gpay', 'me@upi')).success, isTrue);
    expect((await pay('card', '4242 4242 4242 4242')).success, isTrue);
    expect((await pay('netbank', 'HDFC Bank')).success, isTrue);
  });

  test('success carries a transaction id, failure carries a reason', () async {
    final ok = await pay('gpay', 'me@upi');
    expect(ok.transactionId, startsWith('MOCK-'));
    final bad = await pay('card', '4000 0000 0000 0000');
    expect(bad.success, isFalse);
    expect(bad.failureReason, 'Your card was declined.');
  });

  test('the documented test inputs are declined', () async {
    expect((await pay('gpay', 'fail@upi')).success, isFalse);
    expect(
        (await pay('netbank', MockPaymentGateway.downBank)).success, isFalse);
  });

  test('malformed input is rejected before "charging"', () async {
    expect((await pay('gpay', 'no-at-sign')).success, isFalse);
    expect((await pay('card', '1234')).success, isFalse);
    expect((await pay('netbank')).success, isFalse);
  });

  test('cash on delivery always succeeds', () async {
    final r = await pay('cod');
    expect(r.success, isTrue);
    expect(r.transactionId, startsWith('COD-'));
  });
}
