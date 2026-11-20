import 'package:flutter_test/flutter_test.dart';
import 'package:namaste_tripathi/data/backend.dart';
import 'package:namaste_tripathi/main.dart';

void main() {
  // These cover the widgets, not a backend. Supabase mode short-circuits
  // without a key, so nothing is fetched and no timer is left pending.
  setUp(() => Backend.mode = BackendMode.supabase);
  tearDown(Backend.reset);

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
