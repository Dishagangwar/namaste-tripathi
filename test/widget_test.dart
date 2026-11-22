import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:namaste_tripathi/bloc/bookings/bookings_bloc.dart';
import 'package:namaste_tripathi/bloc/cart/cart_bloc.dart';
import 'package:namaste_tripathi/bloc/config/config_bloc.dart';
import 'package:namaste_tripathi/bloc/orders/orders_bloc.dart';
import 'package:namaste_tripathi/bloc/rides/rides_bloc.dart';
import 'package:namaste_tripathi/bloc/session/session_bloc.dart';
import 'package:namaste_tripathi/core/theme.dart';
import 'package:namaste_tripathi/data/backend.dart';
import 'package:namaste_tripathi/data/mock_data.dart';
import 'package:namaste_tripathi/features/biketaxi/bike_taxi_screen.dart';
import 'package:namaste_tripathi/features/food/payment_screen.dart';
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

  testWidgets('placing an order records it and files an itinerary entry',
      (tester) async {
    // Supabase mode with no key, so every repository short-circuits: this
    // test is about the wiring from the button to the blocs.
    //
    // These are not closed at the end: `Bloc.close()` waits on its event
    // queue, which never drains inside `testWidgets`' fake-async zone, so
    // awaiting it hangs the test rather than tidying up after it.
    final cart = CartBloc();
    final orders = OrdersBloc();
    final bookings = BookingsBloc();

    final restaurant = kRestaurants.first;
    cart.add(CartItemAdded(restaurant.menu.first, restaurant));
    await cart.stream.first;

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider.value(value: cart),
          BlocProvider.value(value: orders),
          BlocProvider.value(value: bookings),
          BlocProvider(create: (_) => SessionBloc()),
        ],
        child: MaterialApp(
          theme: buildAppTheme(),
          home: const PaymentScreen(),
        ),
      ),
    );
    await tester.pump();

    expect(orders.state.items, isEmpty);

    await tester.tap(find.text('Place Order'));
    await tester.pump();

    // The order is on the list before any write completes, and the tracker
    // is showing it.
    expect(orders.state.items, hasLength(1));
    expect(orders.state.latest?.restaurantName, restaurant.name);
    expect(orders.state.latest?.lines.single.name, restaurant.menu.first.name);

    // And it shows up as an itinerary entry, not only in order history.
    expect(bookings.state.items.first.kind, 'Food Order');

    // The basket is emptied behind it. Asserted on the state rather than
    // awaited on the stream: the handler runs during the pump above, so a
    // listener added here would wait for an emission that already happened.
    expect(cart.state.isEmpty, isTrue);

    // Let the replacement route finish before looking for the tracker.
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Order Placed\nSuccessfully!'), findsOneWidget);
    // The order id shown is the local one until a write lands; in this test
    // no backend answers, so it stays pending rather than inventing one.
    expect(find.textContaining('ORDER ID:'), findsOneWidget);

    // The tracker nudges itself forward on a 6s timer; let it fire rather
    // than leaving it pending at teardown.
    await tester.pump(const Duration(seconds: 7));
  });

  testWidgets('the bike taxi screen reads its ride classes from config',
      (tester) async {
    final rides = RidesBloc();

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider.value(value: rides),
          BlocProvider(create: (_) => ConfigBloc()),
          BlocProvider(create: (_) => SessionBloc()),
        ],
        child: MaterialApp(
          theme: buildAppTheme(),
          home: Scaffold(body: BikeTaxiScreen(onBack: () {})),
        ),
      ),
    );
    await tester.pump();

    // No destination yet, so the saved places are offered.
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Airport'), findsOneWidget);

    await tester.enterText(
        find.byType(TextField).first, 'Sector 62, Noida');
    await tester.pump();

    // The classes, and a fare computed from the served price per km.
    expect(find.text('Bike taxi'), findsWidgets);
    expect(find.text('E-rickshaw'), findsOneWidget);
    expect(find.text(rupees(kRideOptions.first.fareFor(7.4))), findsWidgets);

    await tester.tap(find.text('Confirm ride'));
    await tester.pump();

    expect(rides.state.items, hasLength(1));
    expect(rides.state.latest?.toAddress, 'Sector 62, Noida');
    expect(rides.state.latest?.rideType, 'Bike taxi');

    // The sheet's progress bar animates indefinitely, so this pumps the
    // route transition rather than settling.
    await tester.pump(const Duration(milliseconds: 400));
  });

  testWidgets('an unconfigured build refuses Google sign-in out loud',
      (tester) async {
    // Supabase mode with no key compiled in. This used to walk straight into
    // the app with no session, then drop every write in silence; the guard
    // now reports it instead.
    await tester.pumpWidget(const NamasteTripathiApp());
    await tester.pump();

    await tester.tap(find.text('Continue with Google'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Still on onboarding, with a message, rather than through to the shell.
    expect(find.text('Continue with OTP'), findsOneWidget);
    expect(
      find.textContaining('cannot sign you in'),
      findsOneWidget,
      reason: 'a build that cannot authenticate has to say so',
    );
  });
}
