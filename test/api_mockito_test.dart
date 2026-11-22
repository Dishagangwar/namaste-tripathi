import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:namaste_tripathi/data/api/api_client.dart';
import 'package:namaste_tripathi/data/api/api_repositories.dart';
import 'package:namaste_tripathi/data/models.dart';
import 'package:namaste_tripathi/data/remote/mappers.dart';
import 'package:namaste_tripathi/data/repositories.dart';

import 'api_mockito_test.mocks.dart';

/// Mockito stands in for Dio here, so the repositories can be driven through
/// responses no real backend would hand you on demand: a timeout, a 500, a
/// body of the wrong shape. The demo backend covers the happy path; these
/// cover what happens when a server misbehaves.
@GenerateNiceMocks([MockSpec<Dio>()])
void main() {
  late MockDio dio;
  late ApiClient client;

  RequestOptions opts(String path) => RequestOptions(path: path);

  Response<dynamic> ok(String path, Object? body) => Response<dynamic>(
        requestOptions: opts(path),
        statusCode: 200,
        data: body,
      );

  setUp(() {
    dio = MockDio();
    client = ApiClient(dio);
  });

  group('ApiClient', () {
    test('parses a JSON array into rows', () async {
      when(dio.get<dynamic>('/catalog/hotels')).thenAnswer(
        (_) async => ok('/catalog/hotels', [
          {'id': 'h1', 'name': 'Skyline Grand'},
        ]),
      );

      final rows = await client.getList('/catalog/hotels');
      expect(rows.single['name'], 'Skyline Grand');
    });

    test('a body of the wrong shape yields no rows rather than throwing',
        () async {
      when(dio.get<dynamic>('/catalog/hotels'))
          .thenAnswer((_) async => ok('/catalog/hotels', {'oops': true}));

      expect(await client.getList('/catalog/hotels'), isEmpty);
    });

    test("a server's own message wins over the generic one", () {
      final error = DioException(
        requestOptions: opts('/auth/verify'),
        type: DioExceptionType.badResponse,
        response: Response<dynamic>(
          requestOptions: opts('/auth/verify'),
          statusCode: 401,
          data: {'message': 'That code is not right'},
        ),
      );
      expect(ApiClient.describeError(error), 'That code is not right');
    });

    test('transport failures are described in plain language', () {
      expect(
        ApiClient.describeError(DioException(
          requestOptions: opts('/bookings'),
          type: DioExceptionType.receiveTimeout,
        )),
        'The server took too long to answer.',
      );
      expect(
        ApiClient.describeError(DioException(
          requestOptions: opts('/bookings'),
          type: DioExceptionType.connectionError,
        )),
        'Could not reach the server.',
      );
    });
  });

  group('ApiCatalogRepository', () {
    test('a nested menu is parsed onto its restaurant', () async {
      when(dio.get<dynamic>(argThat(startsWith('/catalog/')))).thenAnswer(
        (invocation) async {
          final path = invocation.positionalArguments.first as String;
          if (path != '/catalog/restaurants') return ok(path, const []);
          return ok(path, [
            {
              'id': 'r1',
              'name': 'The Obsidian Grill',
              'rating': 4.9,
              'tags': ['All'],
              'menu': [
                {'id': 'm1', 'name': 'Truffle Pasta', 'price': 225},
              ],
            },
          ]);
        },
      );

      final data = await ApiCatalogRepository(client).fetch();
      expect(data.fromRemote, isTrue);
      expect(data.restaurants.single.name, 'The Obsidian Grill');
      expect(data.restaurants.single.menu.single.price, 225);
    });

    test('a failing endpoint falls back to the bundled catalogue', () async {
      when(dio.get<dynamic>(any)).thenThrow(
        DioException(
          requestOptions: opts('/catalog/restaurants'),
          type: DioExceptionType.connectionError,
        ),
      );

      final data = await ApiCatalogRepository(client).fetch();
      expect(data.fromRemote, isFalse);
      expect(data.restaurants, isNotEmpty);
    });
  });

  group('ApiBookingsRepository', () {
    test('posts the booking and returns the row the server stamped', () async {
      when(dio.post<dynamic>('/bookings', data: anyNamed('data'))).thenAnswer(
        (_) async => ok('/bookings', {
          'id': 'server-id-9',
          'title': 'Azure Bay Resort',
          'status': 'confirmed',
        }),
      );

      const local = Booking(
        id: 'local-1',
        title: 'Azure Bay Resort',
        subtitle: 'Ocean Suite',
        kind: 'Luxury Stay',
        when: 'Oct 24',
        status: BookingStatus.confirmed,
        image: 'assets/images/hotel4.jpg',
      );

      final stored = await ApiBookingsRepository(client).add(local);
      expect(stored?.id, 'server-id-9');

      // The id is the server's to assign, so it must not be sent.
      final sent = verify(dio.post<dynamic>('/bookings', data: captureAnyNamed('data')))
          .captured
          .single as Map<String, dynamic>;
      expect(sent.containsKey('id'), isFalse);
      expect(sent['when_label'], 'Oct 24');
    });

    test('a 500 leaves the caller holding its local copy', () async {
      when(dio.post<dynamic>('/bookings', data: anyNamed('data'))).thenThrow(
        DioException(
          requestOptions: opts('/bookings'),
          type: DioExceptionType.badResponse,
          response: Response<dynamic>(
            requestOptions: opts('/bookings'),
            statusCode: 500,
          ),
        ),
      );

      const local = Booking(
        id: 'local-2',
        title: 'Site visit',
        subtitle: '',
        kind: 'Property Visit',
        when: 'Nov 2',
        status: BookingStatus.confirmed,
        image: '',
      );
      expect(await ApiBookingsRepository(client).add(local), isNull);
    });
  });

  group('ApiConfigRepository', () {
    test('a partial payload fills in from the bundled taxonomy', () async {
      // Only the tip and one filter group come back; everything else should
      // hold its bundled value rather than go blank.
      when(dio.get<dynamic>('/config')).thenAnswer(
        (_) async => ok('/config', {
          'traveler_tip': 'Mind the monsoon.',
          'filters': {
            'cuisine': ['All', 'Thali'],
          },
        }),
      );

      final config = await ApiConfigRepository(client).fetch();
      expect(config!.travelerTip, 'Mind the monsoon.');
      expect(config.filtersFor(FilterGroup.cuisine), ['All', 'Thali']);
      // Untouched by the response, so still bundled.
      expect(config.categories, isNotEmpty);
      expect(config.rideOptions, isNotEmpty);
      expect(config.savedPlaces, isNotEmpty);
    });

    test('a body of the wrong shape yields no config at all', () async {
      when(dio.get<dynamic>('/config'))
          .thenAnswer((_) async => ok('/config', const []));

      // null, not a half-built config: the bloc keeps what it has.
      expect(await ApiConfigRepository(client).fetch(), isNull);
    });

    test('a failing endpoint is swallowed', () async {
      when(dio.get<dynamic>('/config')).thenThrow(
        DioException(
          requestOptions: opts('/config'),
          type: DioExceptionType.connectionError,
        ),
      );

      expect(await ApiConfigRepository(client).fetch(), isNull);
    });
  });

  group('ApiOrdersRepository', () {
    const local = FoodOrder(
      id: 'local-7',
      restaurantId: 'r1',
      restaurantName: 'The Obsidian Grill',
      image: 'assets/images/restaurant1.jpg',
      lines: [
        OrderLine(itemId: 'm1', name: 'Truffle Pasta', quantity: 1, price: 540),
      ],
      subtotal: 540,
      deliveryFee: 50,
      taxes: 49,
      discount: 0,
      total: 639,
      paymentMethod: 'gpay',
      couponCode: 'SAVE20',
      instructions: ['No onion'],
    );

    test('posts the order and returns the row the server stamped', () async {
      when(dio.post<dynamic>('/orders', data: anyNamed('data'))).thenAnswer(
        (_) async => ok('/orders', {
          'id': 'server-order-3',
          'restaurant_name': 'The Obsidian Grill',
          'total': 639,
          'status': 'placed',
          'reference': '#NT-123456',
          'lines': [
            {'item_id': 'm1', 'name': 'Truffle Pasta', 'quantity': 1, 'price': 540},
          ],
        }),
      );

      final stored = await ApiOrdersRepository(client).place(local);
      expect(stored?.id, 'server-order-3');
      expect(stored?.reference, '#NT-123456');

      final sent = verify(dio.post<dynamic>('/orders', data: captureAnyNamed('data')))
          .captured
          .single as Map<String, dynamic>;
      // The id is the server's to assign.
      expect(sent.containsKey('id'), isFalse);
      expect(sent['coupon_code'], 'SAVE20');
      expect(sent['instructions'], ['No onion']);
      expect(sent['lines'], hasLength(1));
      expect((sent['lines'] as List).single, containsPair('quantity', 1));
    });

    test('on_the_way survives the round trip in both directions', () async {
      when(dio.get<dynamic>('/orders')).thenAnswer(
        (_) async => ok('/orders', [
          {'id': 'o1', 'status': 'on_the_way'},
        ]),
      );

      final orders = await ApiOrdersRepository(client).fetch();
      expect(orders!.single.status, OrderStatus.onTheWay);
      // The enum name is `onTheWay`, so the wire form cannot be derived
      // from it -- this is the check that the mapping is explicit.
      expect(orderStatusToWire(OrderStatus.onTheWay), 'on_the_way');
    });

    test('a 401 leaves the caller holding its local copy', () async {
      when(dio.post<dynamic>('/orders', data: anyNamed('data'))).thenThrow(
        DioException(
          requestOptions: opts('/orders'),
          type: DioExceptionType.badResponse,
          response: Response<dynamic>(
            requestOptions: opts('/orders'),
            statusCode: 401,
            data: {'message': 'Not signed in'},
          ),
        ),
      );

      expect(await ApiOrdersRepository(client).place(local), isNull);
    });
  });

  group('ApiRidesRepository', () {
    const local = Ride(
      id: 'local-9',
      optionId: 'bike',
      rideType: 'Bike taxi',
      fromAddress: 'Home',
      toAddress: 'Sector 62, Noida',
      distanceKm: 7.4,
      fare: 74,
      eta: '3 min away',
    );

    test('posts the ride and returns the row the server stamped', () async {
      when(dio.post<dynamic>('/rides', data: anyNamed('data'))).thenAnswer(
        (_) async => ok('/rides', {
          'id': 'server-ride-2',
          'option_id': 'bike',
          'ride_type': 'Bike taxi',
          'to_address': 'Sector 62, Noida',
          'distance_km': 7.4,
          'fare': 74,
          'status': 'searching',
          'reference': '#RD-998877',
        }),
      );

      final booked = await ApiRidesRepository(client).book(local);
      expect(booked?.id, 'server-ride-2');
      expect(booked?.reference, '#RD-998877');
      expect(booked?.status, RideStatus.searching);

      final sent = verify(dio.post<dynamic>('/rides', data: captureAnyNamed('data')))
          .captured
          .single as Map<String, dynamic>;
      expect(sent.containsKey('id'), isFalse);
      expect(sent['to_address'], 'Sector 62, Noida');
      expect(sent['distance_km'], 7.4);
    });

    test('an unknown status falls back to searching', () async {
      when(dio.get<dynamic>('/rides')).thenAnswer(
        (_) async => ok('/rides', [
          {'id': 'r1', 'status': 'teleporting'},
        ]),
      );

      final rides = await ApiRidesRepository(client).fetch();
      expect(rides!.single.status, RideStatus.searching);
    });
  });

  group('ApiAuthRepository', () {
    test('numbers are normalised to E.164 before they are sent', () async {
      when(dio.post<dynamic>('/auth/otp', data: anyNamed('data')))
          .thenAnswer((_) async => ok('/auth/otp', {'sent': true}));

      final auth = ApiAuthRepository(client);
      expect(
        await auth.sendOtp(countryCode: '+91', phone: '98765 43210'),
        isNull,
      );

      final sent = verify(dio.post<dynamic>('/auth/otp', data: captureAnyNamed('data')))
          .captured
          .single as Map<String, dynamic>;
      expect(sent['phone'], '+919876543210');
    });

    test('a failed Google sign-in reports the reason, not a session', () async {
      when(dio.post<dynamic>('/auth/google', data: anyNamed('data')))
          .thenThrow(DioException(
        requestOptions: opts('/auth/google'),
        type: DioExceptionType.connectionError,
      ));

      final auth = ApiAuthRepository(client);
      final result = await auth.signInWithGoogle();

      expect(result.outcome, SignInOutcome.failed);
      expect(result.message, 'Could not reach the server.');
      // The important part: no session was granted on a failure.
      expect(auth.isSignedIn, isFalse);
    });

    test('a rejected code comes back as the server worded it', () async {
      when(dio.post<dynamic>('/auth/verify', data: anyNamed('data'))).thenThrow(
        DioException(
          requestOptions: opts('/auth/verify'),
          type: DioExceptionType.badResponse,
          response: Response<dynamic>(
            requestOptions: opts('/auth/verify'),
            statusCode: 401,
            data: {'message': 'That code is not right'},
          ),
        ),
      );

      final auth = ApiAuthRepository(client);
      final error = await auth.verifyOtp(
        countryCode: '+91',
        phone: '9876543210',
        token: '000000',
      );
      expect(error, 'That code is not right');
      expect(auth.isSignedIn, isFalse);
    });
  });
}
