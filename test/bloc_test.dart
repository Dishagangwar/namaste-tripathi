import 'package:flutter_test/flutter_test.dart';
import 'package:namaste_tripathi/bloc/cart/cart_bloc.dart';
import 'package:namaste_tripathi/data/api/api_client.dart';
import 'package:namaste_tripathi/data/api/demo_backend.dart';
import 'package:namaste_tripathi/data/backend.dart';
import 'package:namaste_tripathi/bloc/favourites/favourites_bloc.dart';
import 'package:namaste_tripathi/bloc/session/session_bloc.dart';
import 'package:namaste_tripathi/data/mock_data.dart';

/// The point of moving to events is that every transition is now reachable
/// without a widget tree. These cover the rules that used to live inside the
/// ChangeNotifiers, where only the UI could exercise them.
void main() {
  group('CartBloc', () {
    final burger = kRestaurants[0].menu[1];
    final pasta = kRestaurants[0].menu[0];
    final italian = kRestaurants[1];

    test('starts empty with no bill', () {
      final state = CartBloc().state;
      expect(state.isEmpty, isTrue);
      expect(state.itemCount, 0);
      expect(state.total, 0);
      expect(state.deliveryFee, 0);
    });

    test('adding the same item twice raises its quantity, not its line', () async {
      final bloc = CartBloc()
        ..add(CartItemAdded(pasta, kRestaurants[0]))
        ..add(CartItemAdded(pasta, kRestaurants[0]));
      await bloc.stream.firstWhere((s) => s.itemCount == 2);

      expect(bloc.state.lines.length, 1);
      expect(bloc.state.lines.single.quantity, 2);
      expect(bloc.state.subtotal, pasta.price * 2);
      await bloc.close();
    });

    test('adding from another restaurant replaces the basket', () async {
      final bloc = CartBloc()..add(CartItemAdded(pasta, kRestaurants[0]));
      await bloc.stream.first;

      bloc.add(CartItemAdded(italian.menu.first, italian));
      await bloc.stream.firstWhere((s) => s.restaurant?.id == italian.id);

      expect(bloc.state.lines.length, 1);
      expect(bloc.state.lines.single.item.id, italian.menu.first.id);
      await bloc.close();
    });

    test('removing the last item resets the basket completely', () async {
      final bloc = CartBloc()
        ..add(CartItemAdded(burger, kRestaurants[0]))
        ..add(const CartCouponToggled(null));
      await bloc.stream.first;

      bloc.add(CartItemRemoved(burger));
      await bloc.stream.firstWhere((s) => s.isEmpty);

      expect(bloc.state.restaurant, isNull);
      expect(bloc.state.coupon, isNull);
      await bloc.close();
    });

    test('a coupon only bites once the minimum order is met', () async {
      final save20 = kCoupons.firstWhere((c) => c.code == 'SAVE20');
      final bloc = CartBloc()
        ..add(CartItemAdded(pasta, kRestaurants[0]))
        ..add(CartCouponToggled(save20));
      await bloc.stream.firstWhere((s) => s.coupon != null);

      // One pasta is under the 300 minimum, so no discount yet.
      expect(bloc.state.subtotal, lessThan(save20.minOrder));
      expect(bloc.state.discount, 0);

      bloc.add(CartItemAdded(pasta, kRestaurants[0]));
      await bloc.stream.firstWhere((s) => s.subtotal >= save20.minOrder);
      expect(bloc.state.discount, greaterThan(0));
      await bloc.close();
    });

    test('toggling the applied coupon clears it', () async {
      final coupon = kCoupons.first;
      final bloc = CartBloc()..add(CartCouponToggled(coupon));
      await bloc.stream.firstWhere((s) => s.coupon != null);

      bloc.add(CartCouponToggled(coupon));
      await bloc.stream.firstWhere((s) => s.coupon == null);
      expect(bloc.state.coupon, isNull);
      await bloc.close();
    });

    test('instructions toggle on and off', () async {
      final bloc = CartBloc()..add(const CartInstructionToggled('Pet at Home'));
      await bloc.stream.firstWhere((s) => s.instructions.isNotEmpty);
      expect(bloc.state.instructions, contains('Pet at Home'));

      bloc.add(const CartInstructionToggled('Pet at Home'));
      await bloc.stream.firstWhere((s) => s.instructions.isEmpty);
      await bloc.close();
    });
  });

  group('FavouritesBloc', () {
    test('toggling a property flips it both ways', () async {
      final bloc = FavouritesBloc();
      final wasSaved = bloc.state.isPropertyFavourite('pr6');

      bloc.add(const FavouritePropertyToggled('pr6'));
      await bloc.stream.first;
      expect(bloc.state.isPropertyFavourite('pr6'), !wasSaved);

      bloc.add(const FavouritePropertyToggled('pr6'));
      await bloc.stream.first;
      expect(bloc.state.isPropertyFavourite('pr6'), wasSaved);
      await bloc.close();
    });

    test('restaurants and properties are kept apart', () async {
      final bloc = FavouritesBloc()
        ..add(const FavouriteRestaurantToggled('r3'));
      await bloc.stream.first;

      expect(bloc.state.isRestaurantSaved('r3'), isTrue);
      expect(bloc.state.isPropertyFavourite('r3'), isFalse);
      await bloc.close();
    });
  });

  group('SessionBloc', () {
    // Against the demo backend, with the simulated network removed so the
    // tests do not sit waiting on it.
    setUp(() {
      Backend.mode = BackendMode.demo;
      Backend.client = ApiClient.demo(latency: Duration.zero);
    });
    tearDown(Backend.reset);

    test('holds the typed number and country code', () async {
      final bloc = SessionBloc()
        ..add(const SessionCountryCodeChanged('+44'))
        ..add(const SessionPhoneChanged('7700900123'));
      await bloc.stream.firstWhere((s) => s.phone.isNotEmpty);

      expect(bloc.state.countryCode, '+44');
      expect(bloc.state.phone, '7700900123');
      await bloc.close();
    });

    test('requesting a code for a real number reports it sent', () async {
      final bloc = SessionBloc()
        ..add(const SessionPhoneChanged('9876543210'))
        ..add(const OtpRequested());
      final state = await bloc.stream.firstWhere((s) =>
          s.status == SessionStatus.otpSent ||
          s.status == SessionStatus.failure);

      expect(state.status, SessionStatus.otpSent);
      expect(state.errorMessage, isNull);
      await bloc.close();
    });

    test("a number the backend rejects surfaces the server's wording",
        () async {
      // No number has been entered, so the demo backend 422s rather than
      // pretending to send.
      final bloc = SessionBloc()..add(const OtpRequested());
      final state = await bloc.stream.firstWhere((s) => !s.isSendingOtp);

      expect(state.status, SessionStatus.failure);
      expect(state.errorMessage, 'Invalid phone number');
      await bloc.close();
    });

    test('the demo code signs in and anything else does not', () async {
      final bloc = SessionBloc()
        ..add(const SessionPhoneChanged('9876543210'))
        ..add(const OtpSubmitted('000000'));
      final state = await bloc.stream.firstWhere((s) =>
          s.status == SessionStatus.authenticated ||
          s.status == SessionStatus.failure);
      expect(state.status, SessionStatus.failure);
      expect(state.errorMessage, 'That code is not right');

      bloc.add(const OtpSubmitted(DemoBackend.demoOtp));
      await bloc.stream
          .firstWhere((s) => s.status == SessionStatus.authenticated);
      expect(bloc.isSignedIn, isTrue);
      await bloc.close();
    });

    test('selecting a role lands in state', () async {
      final bloc = SessionBloc()
        ..add(const SessionRoleSelected(JoinRole.provider));
      await bloc.stream.first;
      expect(bloc.state.role, JoinRole.provider);
      await bloc.close();
    });

    test('signing out returns to a blank session', () async {
      final bloc = SessionBloc()
        ..add(const SessionNameChanged('Disha'))
        ..add(const SessionLocationChanged('Work', 'Sector 62'));
      await bloc.stream.firstWhere((s) => s.location == 'Work');

      bloc.add(const SessionSignedOut());
      await bloc.stream.firstWhere((s) => s.location == 'Home');

      expect(bloc.state.name, 'Darsh');
      expect(bloc.state.location, 'Home');
      await bloc.close();
    });
  });
}
