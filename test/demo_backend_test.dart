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
