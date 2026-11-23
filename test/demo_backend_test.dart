import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:namaste_tripathi/data/api/api_client.dart';
import 'package:namaste_tripathi/data/api/api_repositories.dart';
import 'package:namaste_tripathi/data/api/demo_backend.dart';
import 'package:namaste_tripathi/data/models.dart';

/// The demo backend driven through real Dio, with no mocks: these are the
/// end-to-end checks that the app has a working server to develop against.
void main() {
  late ApiClient client;

  setUp(() {
    // No latency, so tests do not sit waiting on a simulated network.
    client = ApiClient(
      Dio(BaseOptions(baseUrl: 'https://demo.local'))
        ..interceptors.add(DemoBackend(latency: Duration.zero)),
    );
  });

  test('serves the whole catalogue', () async {
    final data = await ApiCatalogRepository(client).fetch();

    expect(data.fromRemote, isTrue);
    expect(data.restaurants, hasLength(6));
    expect(data.hotels, hasLength(5));
    expect(data.properties, hasLength(8));
    expect(data.providers, hasLength(8));
    expect(data.offers, hasLength(4));
    expect(data.coupons, hasLength(3));
  });

  test('round-trips the things that cannot travel as objects', () async {
    final data = await ApiCatalogRepository(client).fetch();

    // Colours go over the wire as hex and come back as Color.
    final electrician = data.providers.firstWhere((p) => p.id == 'sp1');
    expect(electrician.professionColor.toARGB32(), 0xFF7A4F00);

    // Icons go as registry names and come back as IconData.
    expect(electrician.expertise.first.label, 'Wiring & Panels');
    expect(electrician.expertise.first.icon.codePoint, isNonZero);

    // Menus arrive nested on their restaurant.
    final grill = data.restaurants.firstWhere((r) => r.id == 'r1');
    expect(grill.menu, hasLength(8));
    expect(grill.menu.first.name, 'Obsidian Truffle Pasta');
  });

  test('a posted booking is visible to the next read', () async {
    final repo = ApiBookingsRepository(client);
    final before = await repo.fetch();

    const booking = Booking(
      id: 'local',
      title: 'Lakeside Manor',
      subtitle: 'Site visit',
      kind: 'Property Visit',
      when: 'Nov 20, 2026 • 11:00 AM',
      status: BookingStatus.confirmed,
      image: 'assets/images/property1.jpg',
    );

    final stored = await repo.add(booking);
    expect(stored, isNotNull);
    // The backend assigns the id, as a real one would.
    expect(stored!.id, isNot('local'));
    expect(stored.title, 'Lakeside Manor');

    final after = await repo.fetch();
    expect(after!.length, before!.length + 1);
    expect(after.first.id, stored.id);
  });

  test('favourites persist across calls', () async {
    final repo = ApiFavouritesRepository(client);

    await repo.add('property', 'pr1');
    var saved = await repo.fetch();
    expect(saved!['property'], contains('pr1'));

    await repo.remove('property', 'pr1');
    saved = await repo.fetch();
    expect(saved!['property'], isNot(contains('pr1')));
  });

  group('auth', () {
    test('rejects a malformed number before sending anything', () async {
      final auth = ApiAuthRepository(client);
      expect(await auth.sendOtp(countryCode: '+91', phone: '12'),
          'Invalid phone number');
    });

    test('accepts the demo code and refuses anything else', () async {
      final auth = ApiAuthRepository(client);
      expect(await auth.sendOtp(countryCode: '+91', phone: '9876543210'),
          isNull);

      expect(
        await auth.verifyOtp(
            countryCode: '+91', phone: '9876543210', token: '000000'),
        'That code is not right',
      );
      expect(auth.isSignedIn, isFalse);

      expect(
        await auth.verifyOtp(
          countryCode: '+91',
          phone: '9876543210',
          token: DemoBackend.demoOtp,
        ),
        isNull,
      );
      expect(auth.isSignedIn, isTrue);
    });

    test('Google sign-in grants a session without any console setup', () async {
      // Demo mode is what a keyless build falls back to, so this path has to
      // work with no client IDs and no Google SDK involved.
      final auth = ApiAuthRepository(client);
      expect(auth.isSignedIn, isFalse);

      final result = await auth.signInWithGoogle();
      expect(result.isSignedIn, isTrue);
      expect(result.isCancelled, isFalse);
      expect(auth.isSignedIn, isTrue);

      // And it admits what it is. Without this the demo backend is a
      // convincing impersonation of a working Google integration.
      expect(result.isDemo, isTrue);

      // And it is a real session as far as the rest of the backend cares.
      expect((await auth.fetchProfile())?['full_name'], 'Demo User');
      expect(await ApiOrdersRepository(client).fetch(), isNotNull);
    });

    test('the profile is gated on being signed in', () async {
      final auth = ApiAuthRepository(client);
      expect(await auth.fetchProfile(), isNull);

      await auth.verifyOtp(
        countryCode: '+91',
        phone: '9876543210',
        token: DemoBackend.demoOtp,
      );
      final profile = await auth.fetchProfile();
      expect(profile?['full_name'], 'Demo User');
    });
  });

  group('config', () {
    test('serves the whole taxonomy', () async {
      final config = await ApiConfigRepository(client).fetch();

      expect(config, isNotNull);
      // Four grid tiles plus the wide one, split apart by the parser.
      expect(config!.categories, hasLength(4));
      expect(config.wideCategory.id, 'providers');
      expect(config.savedPlaces, hasLength(3));
      expect(config.rideOptions, hasLength(4));
      expect(config.travelerTip, isNotEmpty);
    });

    test('filter groups come back keyed as the screens ask for them', () async {
      final config = await ApiConfigRepository(client).fetch();

      expect(config!.filtersFor(FilterGroup.cuisine).first, 'All');
      expect(config.filtersFor(FilterGroup.hotel), contains('Heritage'));
      expect(config.filtersFor(FilterGroup.property), contains('For Rent'));
      expect(config.filtersFor(FilterGroup.provider), contains('Plumbers'));
      // A group nobody serves still yields a usable chip row.
      expect(config.filtersFor('nope'), ['All']);
    });

    test('icons and colours survive the trip', () async {
      final config = await ApiConfigRepository(client).fetch();

      final bike = config!.rideOptions.firstWhere((r) => r.id == 'bike');
      expect(bike.icon.codePoint, isNonZero);
      expect(bike.color.toARGB32(), 0xFF7A4F00);
      expect(bike.pricePerKm, 8);
      // 8 x 7.4 = 59.2, rounded, plus the flag-down charge.
      expect(bike.fareFor(7.4), 59 + RideOption.baseFare);
    });

    test('is readable before anyone signs in', () async {
      // The home screen needs its tiles during onboarding.
      expect(await ApiConfigRepository(client).fetch(), isNotNull);
    });
  });

  group('orders', () {
    const order = FoodOrder(
      id: 'local',
      restaurantId: 'r1',
      restaurantName: 'The Obsidian Grill',
      image: 'assets/images/restaurant1.jpg',
      lines: [
        OrderLine(itemId: 'm1', name: 'Truffle Pasta', quantity: 2, price: 540),
      ],
      subtotal: 1080,
      deliveryFee: 50,
      taxes: 97,
      discount: 0,
      total: 1227,
      paymentMethod: 'gpay',
    );

    Future<void> signIn() => ApiAuthRepository(client).verifyOtp(
          countryCode: '+91',
          phone: '9876543210',
          token: DemoBackend.demoOtp,
        );

    test('placing one is gated on being signed in', () async {
      expect(await ApiOrdersRepository(client).place(order), isNull);
      expect(await ApiOrdersRepository(client).fetch(), isNull);
    });

    test('a placed order comes back with a server id and reference', () async {
      await signIn();
      final repo = ApiOrdersRepository(client);
      final before = await repo.fetch();

      final stored = await repo.place(order);
      expect(stored, isNotNull);
      expect(stored!.id, isNot('local'));
      expect(stored.reference, startsWith('#NT-'));
      expect(stored.status, OrderStatus.placed);
      expect(stored.placedAt, isNotNull);

      // The bill is stored as it was, not recomputed.
      expect(stored.total, 1227);
      expect(stored.lines.single.label, '2 × Truffle Pasta');
      expect(stored.itemCount, 2);

      final after = await repo.fetch();
      expect(after!.length, before!.length + 1);
      expect(after.first.id, stored.id);
    });

    test('an order with no lines is refused', () async {
      await signIn();
      const empty = FoodOrder(
        id: 'local',
        restaurantId: 'r1',
        restaurantName: 'The Obsidian Grill',
        image: '',
        lines: [],
        subtotal: 0,
        deliveryFee: 0,
        taxes: 0,
        discount: 0,
        total: 0,
        paymentMethod: 'cod',
      );

      expect(await ApiOrdersRepository(client).place(empty), isNull);
    });

    test('the seeded history parses, on_the_way included', () async {
      await signIn();
      final orders = await ApiOrdersRepository(client).fetch();

      expect(orders, isNotEmpty);
      expect(orders!.last.reference, '#NT-884120');
      expect(orders.last.status, OrderStatus.delivered);
    });
  });

  group('rides', () {
    const ride = Ride(
      id: 'local',
      optionId: 'bike',
      rideType: 'Bike taxi',
      fromAddress: 'Diya Green City, Rajnagar Extension',
      toAddress: 'Sector 62, Noida',
      distanceKm: 7.4,
      fare: 74,
      eta: '3 min away',
    );

    Future<void> signIn() => ApiAuthRepository(client).verifyOtp(
          countryCode: '+91',
          phone: '9876543210',
          token: DemoBackend.demoOtp,
        );

    test('booking one is gated on being signed in', () async {
      expect(await ApiRidesRepository(client).book(ride), isNull);
    });

    test('a booked ride comes back searching, with a reference', () async {
      await signIn();
      final repo = ApiRidesRepository(client);
      final before = await repo.fetch();

      final booked = await repo.book(ride);
      expect(booked, isNotNull);
      expect(booked!.id, isNot('local'));
      expect(booked.reference, startsWith('#RD-'));
      // No driver yet, whatever the client asked for.
      expect(booked.status, RideStatus.searching);
      expect(booked.fare, 74);
      expect(booked.distanceKm, 7.4);

      final after = await repo.fetch();
      expect(after!.length, before!.length + 1);
    });

    test('a ride with no destination is refused', () async {
      await signIn();
      expect(
        await ApiRidesRepository(client).book(
          const Ride(
            id: 'local',
            optionId: 'bike',
            rideType: 'Bike taxi',
            fromAddress: 'Home',
            toAddress: '   ',
            distanceKm: 1,
            fare: 23,
            eta: '3 min away',
          ),
        ),
        isNull,
      );
    });
  });

  test('an unknown route 404s rather than hanging', () async {
    await expectLater(
      client.getList('/nope'),
      throwsA(isA<DioException>().having(
        (e) => e.response?.statusCode,
        'statusCode',
        404,
      )),
    );
  });

  test('injected failures surface as connection errors', () async {
    final flaky = ApiClient(
      Dio(BaseOptions(baseUrl: 'https://demo.local'))
        ..interceptors.add(
          DemoBackend(latency: Duration.zero, failureRate: 1),
        ),
    );

    // Every call fails, so the catalogue falls back to the bundled lists.
    final data = await ApiCatalogRepository(flaky).fetch();
    expect(data.fromRemote, isFalse);
  });
}
