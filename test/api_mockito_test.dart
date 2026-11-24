import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:namaste_tripathi/data/api/api_client.dart';
import 'package:namaste_tripathi/data/api/api_repositories.dart';
import 'package:namaste_tripathi/data/api/api_service.dart';
import 'package:namaste_tripathi/data/api/wire.dart';
import 'package:namaste_tripathi/data/models.dart';
import 'package:namaste_tripathi/data/remote/mappers.dart';
import 'package:namaste_tripathi/data/repositories.dart';

import 'api_mockito_test.mocks.dart';

/// Mockito stands in for the generated Retrofit client here, so the
/// repositories can be driven through responses no real backend would hand
/// you on demand: a 500, a 401, a payload missing half its fields.
///
/// The demo backend covers the happy path end to end through real Dio; this
/// file covers what happens when a server misbehaves, and what the
/// repositories send when they write.
@GenerateNiceMocks([MockSpec<ApiService>(), MockSpec<Dio>()])
void main() {
  late MockApiService api;
  late ApiClient client;

  RequestOptions opts(String path) => RequestOptions(path: path);

  DioException failure(
    String path, {
    int? status,
    Object? body,
    DioExceptionType type = DioExceptionType.badResponse,
  }) =>
      DioException(
        requestOptions: opts(path),
        type: type,
        response: status == null
            ? null
            : Response<dynamic>(
                requestOptions: opts(path),
                statusCode: status,
                data: body,
              ),
      );

  setUp(() {
    api = MockApiService();
    // The repositories only ever reach for client.service, so the Dio
    // underneath is never touched.
    client = ApiClient(MockDio(), service: api);
  });

  group('describeError', () {
    test("a server's own message wins over the generic one", () {
      expect(
        ApiClient.describeError(failure(
          '/auth/verify',
          status: 401,
          body: {'message': 'That code is not right'},
        )),
        'That code is not right',
      );
    });

    test('transport failures are described in plain language', () {
      expect(
        ApiClient.describeError(
          failure('/bookings', type: DioExceptionType.receiveTimeout),
        ),
        'The server took too long to answer.',
      );
      expect(
        ApiClient.describeError(
          failure('/bookings', type: DioExceptionType.connectionError),
        ),
        'Could not reach the server.',
      );
    });

    test('something that is not a Dio failure still reads sensibly', () {
      expect(ApiClient.describeError(StateError('boom')),
          'Something went wrong.');
    });
  });

  group('ApiCatalogRepository', () {
    test('a failing endpoint falls back to the bundled catalogue', () async {
      when(api.restaurants()).thenThrow(
        failure('/catalog/restaurants', type: DioExceptionType.connectionError),
      );

      final data = await ApiCatalogRepository(client).fetch();
      expect(data.fromRemote, isFalse);
      expect(data.restaurants, isNotEmpty);
    });

    test('an endpoint that answers empty falls back for that list only',
        () async {
      when(api.restaurants()).thenAnswer((_) async => []);
      when(api.hotels()).thenAnswer(
        (_) async => [HotelWire.fromJson({'id': 'h9', 'name': 'Solo'})],
      );
      when(api.properties()).thenAnswer((_) async => []);
      when(api.providers()).thenAnswer((_) async => []);
      when(api.offers()).thenAnswer((_) async => []);
      when(api.coupons()).thenAnswer((_) async => []);

      final data = await ApiCatalogRepository(client).fetch();
      expect(data.fromRemote, isTrue);
      expect(data.hotels.single.name, 'Solo');
      // The empty ones keep their bundled contents rather than blanking.
      expect(data.restaurants, isNotEmpty);
    });
  });

  group('ApiConfigRepository', () {
    test('a failing endpoint is swallowed', () async {
      when(api.config()).thenThrow(
        failure('/config', type: DioExceptionType.connectionError),
      );
      // null, not a half-built config: the bloc keeps what it has.
      expect(await ApiConfigRepository(client).fetch(), isNull);
    });
  });

  group('ApiBookingsRepository', () {
    const local = Booking(
      id: 'local-1',
      title: 'Azure Bay Resort',
      subtitle: 'Ocean Suite',
      kind: 'Luxury Stay',
      when: 'Oct 24',
      status: BookingStatus.confirmed,
      image: 'assets/images/hotel4.jpg',
    );

    test('posts the booking and returns the row the server stamped', () async {
      when(api.addBooking(any)).thenAnswer(
        (_) async => BookingWire.fromJson({
          'id': 'server-id-9',
          'title': 'Azure Bay Resort',
          'status': 'confirmed',
        }),
      );

      final stored = await ApiBookingsRepository(client).add(local);
      expect(stored?.id, 'server-id-9');

      // The id is the server's to assign, so it must not be sent.
      final sent = verify(api.addBooking(captureAny)).captured.single
          as Map<String, dynamic>;
      expect(sent.containsKey('id'), isFalse);
      expect(sent['when_label'], 'Oct 24');
    });

    test('a 500 leaves the caller holding its local copy', () async {
      when(api.addBooking(any)).thenThrow(failure('/bookings', status: 500));
      expect(await ApiBookingsRepository(client).add(local), isNull);
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
      when(api.placeOrder(any)).thenAnswer(
        (_) async => OrderWire.fromJson({
          'id': 'server-order-3',
          'restaurant_name': 'The Obsidian Grill',
          'total': 639,
          'status': 'placed',
          'reference': '#NT-123456',
        }),
      );

      final stored = await ApiOrdersRepository(client).place(local);
      expect(stored?.id, 'server-order-3');
      expect(stored?.reference, '#NT-123456');

      final sent =
          verify(api.placeOrder(captureAny)).captured.single as Map<String, dynamic>;
      expect(sent.containsKey('id'), isFalse);
      expect(sent['coupon_code'], 'SAVE20');
      expect(sent['instructions'], ['No onion']);
      expect((sent['lines'] as List).single, containsPair('quantity', 1));
    });

    test('on_the_way survives the round trip in both directions', () async {
      when(api.orders()).thenAnswer(
        (_) async => [OrderWire.fromJson({'id': 'o1', 'status': 'on_the_way'})],
      );

      final orders = await ApiOrdersRepository(client).fetch();
      expect(orders!.single.status, OrderStatus.onTheWay);
      // The enum name is `onTheWay`, so the wire form cannot be derived from
      // it -- this is the check that the mapping is explicit.
      expect(orderStatusToWire(OrderStatus.onTheWay), 'on_the_way');
    });

    test('a 401 leaves the caller holding its local copy', () async {
      when(api.placeOrder(any)).thenThrow(failure(
        '/orders',
        status: 401,
        body: {'message': 'Not signed in'},
      ));
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
      when(api.bookRide(any)).thenAnswer(
        (_) async => RideWire.fromJson({
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

      final sent =
          verify(api.bookRide(captureAny)).captured.single as Map<String, dynamic>;
      expect(sent.containsKey('id'), isFalse);
      expect(sent['to_address'], 'Sector 62, Noida');
      expect(sent['distance_km'], 7.4);
    });

    test('an unknown status falls back to searching', () async {
      when(api.rides()).thenAnswer(
        (_) async => [RideWire.fromJson({'id': 'r1', 'status': 'teleporting'})],
      );

      final rides = await ApiRidesRepository(client).fetch();
      expect(rides!.single.status, RideStatus.searching);
    });
  });

  group('ApiAuthRepository', () {
    test('numbers are normalised to E.164 before they are sent', () async {
      when(api.sendOtp(any)).thenAnswer((_) async {});

      final auth = ApiAuthRepository(client);
      expect(await auth.sendOtp(countryCode: '+91', phone: '98765 43210'),
          isNull);

      final sent =
          verify(api.sendOtp(captureAny)).captured.single as Map<String, dynamic>;
      expect(sent['phone'], '+919876543210');
    });

    test('a rejected code comes back as the server worded it', () async {
      when(api.verifyOtp(any)).thenThrow(failure(
        '/auth/verify',
        status: 401,
        body: {'message': 'That code is not right'},
      ));

      final auth = ApiAuthRepository(client);
      expect(
        await auth.verifyOtp(
            countryCode: '+91', phone: '9876543210', token: '000000'),
        'That code is not right',
      );
      expect(auth.isSignedIn, isFalse);
    });

    test('a failed Google sign-in reports the reason, not a session', () async {
      when(api.signInWithGoogle()).thenThrow(
        failure('/auth/google', type: DioExceptionType.connectionError),
      );

      final auth = ApiAuthRepository(client);
      final result = await auth.signInWithGoogle();

      expect(result.outcome, SignInOutcome.failed);
      expect(result.message, 'Could not reach the server.');
      // The important part: no session was granted on a failure.
      expect(auth.isSignedIn, isFalse);
    });
  });
}
