import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:namaste_tripathi/data/api/api_client.dart';
import 'package:namaste_tripathi/data/api/api_repositories.dart';
import 'package:namaste_tripathi/data/models.dart';

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
