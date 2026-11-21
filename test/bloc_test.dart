import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:namaste_tripathi/bloc/cart/cart_bloc.dart';
import 'package:namaste_tripathi/data/api/api_client.dart';
import 'package:namaste_tripathi/data/api/demo_backend.dart';
import 'package:namaste_tripathi/data/backend.dart';
import 'package:namaste_tripathi/bloc/favourites/favourites_bloc.dart';
import 'package:namaste_tripathi/bloc/session/session_bloc.dart';
import 'package:namaste_tripathi/bloc/config/config_bloc.dart';
import 'package:namaste_tripathi/bloc/orders/orders_bloc.dart';
import 'package:namaste_tripathi/bloc/rides/rides_bloc.dart';
import 'package:namaste_tripathi/data/mock_data.dart';
import 'package:namaste_tripathi/data/models.dart';
import 'package:namaste_tripathi/data/repositories.dart';

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

  group('ConfigBloc', () {
    test('starts on the bundled taxonomy, before anything is fetched', () {
      final state = ConfigBloc(repository: _FakeConfig(null)).state;

      expect(state.categories, isNotEmpty);
      expect(state.wideCategory.id, 'providers');
      expect(state.rideOptions, isNotEmpty);
      expect(state.savedPlaces, isNotEmpty);
      expect(state.travelerTip, isNotEmpty);
      expect(state.fromRemote, isFalse);
    });

    test('a backend that cannot answer leaves the bundled values standing',
        () async {
      final bloc = ConfigBloc(repository: _FakeConfig(null))
        ..add(const ConfigRequested());
      await bloc.stream.firstWhere((s) => s.status == ConfigStatus.ready);

      // The screens must never be left with empty chip rows or no tiles.
      expect(bloc.state.categories, isNotEmpty);
      expect(bloc.state.filtersFor(FilterGroup.cuisine), isNotEmpty);
      expect(bloc.state.fromRemote, isFalse);
      await bloc.close();
    });

    test('a served taxonomy replaces the bundled one', () async {
      const served = AppConfig(
        categories: [ServiceCategory('food', 'Khaana', Icons.restaurant)],
        wideCategory: ServiceCategory('pros', 'Pros', Icons.handyman),
        savedPlaces: [
          SavedPlace(id: 'h', icon: Icons.home, label: 'Ghar', address: 'A'),
        ],
        rideOptions: [
          RideOption(
            id: 'bike',
            title: 'Bike',
            subtitle: '',
            icon: Icons.two_wheeler,
            color: Color(0xFF000000),
            eta: '2 min',
            pricePerKm: 9,
          ),
        ],
        filters: {'cuisine': ['All', 'Thali']},
        travelerTip: 'Carry water.',
      );

      final bloc = ConfigBloc(repository: _FakeConfig(served))
        ..add(const ConfigRequested());
      await bloc.stream.firstWhere((s) => s.fromRemote);

      expect(bloc.state.categories.single.label, 'Khaana');
      expect(bloc.state.wideCategory.label, 'Pros');
      expect(bloc.state.travelerTip, 'Carry water.');
      expect(bloc.state.filtersFor(FilterGroup.cuisine), ['All', 'Thali']);
      await bloc.close();
    });
  });

  group('OrdersBloc', () {
    const local = FoodOrder(
      id: 'local-1',
      restaurantId: 'r1',
      restaurantName: 'The Obsidian Grill',
      image: '',
      lines: [
        OrderLine(itemId: 'm1', name: 'Pasta', quantity: 2, price: 100),
      ],
      subtotal: 200,
      deliveryFee: 50,
      taxes: 18,
      discount: 0,
      total: 268,
      paymentMethod: 'gpay',
    );

    test('starts with no orders', () {
      expect(OrdersBloc(repository: _FakeOrders()).state.items, isEmpty);
    });

    test('an order appears at once, then picks up the server reference',
        () async {
      final stored = local.copyWith(id: 'server-1', reference: '#NT-100001');
      final repo = _FakeOrders(stored: stored);
      final bloc = OrdersBloc(repository: repo);

      bloc.add(const OrderPlaced(local));

      // First emission is optimistic: the user has already left for the
      // tracker, so the order has to be on the list before the write lands.
      final optimistic = await bloc.stream.first;
      expect(optimistic.items.single.id, 'local-1');
      expect(optimistic.items.single.reference, isNull);
      expect(optimistic.isPlacing, isTrue);

      await bloc.stream.firstWhere((s) => s.status == OrdersStatus.ready);
      expect(bloc.state.items.single.id, 'server-1');
      expect(bloc.state.latest?.reference, '#NT-100001');
      expect(repo.placeCalls, 1);
      await bloc.close();
    });

    test('a failed write keeps the order on screen and flags it', () async {
      final bloc = OrdersBloc(repository: _FakeOrders(stored: null))
        ..add(const OrderPlaced(local));
      await bloc.stream.firstWhere((s) => s.status == OrdersStatus.failed);

      // Losing the order from the list would be the greater surprise.
      expect(bloc.state.items.single.id, 'local-1');
      await bloc.close();
    });

    test('history loads newest first', () async {
      final older = local.copyWith(id: 'o-old');
      const newer = FoodOrder(
        id: 'o-new',
        restaurantId: 'r2',
        restaurantName: 'Pasta Paradise',
        image: '',
        lines: [],
        subtotal: 0,
        deliveryFee: 0,
        taxes: 0,
        discount: 0,
        total: 0,
        paymentMethod: 'cod',
      );

      final bloc = OrdersBloc(repository: _FakeOrders(history: [newer, older]))
        ..add(const OrdersRequested());
      await bloc.stream.firstWhere((s) => s.status == OrdersStatus.ready);

      expect(bloc.state.items.map((o) => o.id), ['o-new', 'o-old']);
      expect(bloc.state.latest?.id, 'o-new');
      await bloc.close();
    });

    test('a null fetch keeps whatever is already listed', () async {
      final bloc = OrdersBloc(repository: _FakeOrders(stored: local))
        ..add(const OrderPlaced(local));
      await bloc.stream.firstWhere((s) => s.status == OrdersStatus.ready);

      bloc.add(const OrdersRequested());
      await bloc.stream.firstWhere((s) => s.status == OrdersStatus.ready);
      expect(bloc.state.items, hasLength(1));
      await bloc.close();
    });
  });

  group('RidesBloc', () {
    const local = Ride(
      id: 'local-1',
      optionId: 'bike',
      rideType: 'Bike taxi',
      fromAddress: 'Home',
      toAddress: 'Sector 62',
      distanceKm: 7.4,
      fare: 74,
      eta: '3 min away',
    );

    test('a booked ride picks up the server reference', () async {
      final stored = local.copyWith(id: 'server-1', reference: '#RD-100001');
      final bloc = RidesBloc(repository: _FakeRides(stored: stored))
        ..add(const RideBooked(local));

      final optimistic = await bloc.stream.first;
      expect(optimistic.isBooking, isTrue);
      expect(optimistic.latest?.id, 'local-1');

      await bloc.stream.firstWhere((s) => s.status == RidesStatus.ready);
      expect(bloc.state.latest?.reference, '#RD-100001');
      await bloc.close();
    });

    test('cancelling flips the ride without touching the backend', () async {
      final repo = _FakeRides(stored: local);
      final bloc = RidesBloc(repository: repo)..add(const RideBooked(local));
      await bloc.stream.firstWhere((s) => s.status == RidesStatus.ready);

      bloc.add(const RideCancelled('local-1'));
      await bloc.stream.firstWhere(
          (s) => s.latest?.status == RideStatus.cancelled);

      expect(repo.bookCalls, 1);
      await bloc.close();
    });

    test('history loads into the list', () async {
      final bloc = RidesBloc(
        repository: _FakeRides(history: [local.copyWith(id: 'r-past')]),
      )..add(const RidesRequested());
      await bloc.stream.firstWhere((s) => s.status == RidesStatus.ready);

      expect(bloc.state.items.single.id, 'r-past');
      await bloc.close();
    });

    test('a failed booking is flagged but the ride stays listed', () async {
      final bloc = RidesBloc(repository: _FakeRides(stored: null))
        ..add(const RideBooked(local));
      await bloc.stream.firstWhere((s) => s.status == RidesStatus.failed);

      expect(bloc.state.items.single.id, 'local-1');
      await bloc.close();
    });
  });
}

/// Hand-written stand-ins rather than mocks: these blocs are interesting
/// precisely when a repository answers `null`, which is a one-line fake.
class _FakeConfig implements ConfigSource {
  _FakeConfig(this.result);
  final AppConfig? result;

  @override
  Future<AppConfig?> fetch() async => result;
}

class _FakeOrders implements OrdersSource {
  _FakeOrders({this.history, this.stored});
  final List<FoodOrder>? history;
  final FoodOrder? stored;
  int placeCalls = 0;

  @override
  Future<List<FoodOrder>?> fetch() async => history;

  @override
  Future<FoodOrder?> place(FoodOrder order) async {
    placeCalls++;
    return stored;
  }
}

class _FakeRides implements RidesSource {
  _FakeRides({this.history, this.stored});
  final List<Ride>? history;
  final Ride? stored;
  int bookCalls = 0;

  @override
  Future<List<Ride>?> fetch() async => history;

  @override
  Future<Ride?> book(Ride ride) async {
    bookCalls++;
    return stored;
  }
}
