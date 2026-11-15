import 'package:flutter_test/flutter_test.dart';

import 'package:namaste_tripathi/main.dart';

void main() {
  testWidgets('onboarding shows the sign-in options', (tester) async {
    await tester.pumpWidget(const NamasteTripathiApp());
    await tester.pump();

    expect(find.text('Continue with OTP'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
  });

  testWidgets('OTP path reaches the mobile number screen', (tester) async {
    await tester.pumpWidget(const NamasteTripathiApp());
    await tester.pump();

    await tester.tap(find.text('Continue with OTP'));
    await tester.pumpAndSettle();

    expect(find.text('Enter Your Mobile Number'), findsOneWidget);
  });
}
