import 'dart:math';

import 'package:dio/dio.dart';

import 'demo_dataset.dart';

/// A backend that lives inside the app.
///
/// Registered as a Dio interceptor, it answers requests before they reach
/// the network, so every layer above it -- client, repositories, blocs,
/// widgets -- runs exactly as it would against a real server. The app has no
/// idea it is talking to a fake.
///
/// It is deliberately not a silent happy path: it holds mutable state
/// between calls, applies latency, and can be told to fail, so error and
/// loading paths are reachable in a demo.
class DemoBackend extends Interceptor {
  DemoBackend({
    this.latency = const Duration(milliseconds: 400),
    this.failureRate = 0,
    Random? random,
  })  : _random = random ?? Random(),
        _bookings = [...DemoDataset.bookings];

  /// Simulated round trip. Zero makes tests instant.
  final Duration latency;

  /// 0..1 chance that any call fails, for exercising error states.
  final double failureRate;

  final Random _random;

  /// Mutable so a booking POSTed in one screen is visible to the next GET.
  final List<Map<String, dynamic>> _bookings;
  final Set<String> _favouriteProperties = {'pr6', 'pr4', 'pr2'};
  final Set<String> _favouriteRestaurants = {'r1'};

  /// The code the demo backend accepts from any number.
  static const demoOtp = '123456';

  bool _signedIn = false;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (latency > Duration.zero) await Future<void>.delayed(latency);

    if (failureRate > 0 && _random.nextDouble() < failureRate) {
      return handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
          error: 'Demo backend: injected failure',
        ),
      );
    }

    final path = options.path;
    final method = options.method.toUpperCase();
    final body = options.data is Map
        ? Map<String, dynamic>.from(options.data as Map)
        : const <String, dynamic>{};

    final result = _route(method, path, body);
    if (result == null) {
      return handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.badResponse,
          response: Response<dynamic>(
            requestOptions: options,
            statusCode: 404,
            data: {'message': 'No demo route for $method $path'},
          ),
        ),
      );
    }

    final response = Response<dynamic>(
      requestOptions: options,
      statusCode: result.status,
      data: result.body,
    );

    // resolve() bypasses Dio's status validation, so a 401 would reach the
    // caller looking like a success. Real servers make Dio throw on a bad
    // status, and so does this one.
    if (result.status >= 400) {
      return handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.badResponse,
          response: response,
        ),
      );
    }

    handler.resolve(response);
  }

  _DemoResponse? _route(String method, String path, Map<String, dynamic> body) {
    switch ('$method $path') {
      case 'GET /catalog/restaurants':
        return _DemoResponse(200, DemoDataset.restaurants);
      case 'GET /catalog/hotels':
        return _DemoResponse(200, DemoDataset.hotels);
      case 'GET /catalog/properties':
        return _DemoResponse(200, DemoDataset.properties);
      case 'GET /catalog/providers':
        return _DemoResponse(200, DemoDataset.providers);
      case 'GET /catalog/offers':
        return _DemoResponse(200, DemoDataset.offers);
      case 'GET /catalog/coupons':
        return _DemoResponse(200, DemoDataset.coupons);

      case 'POST /auth/otp':
        final phone = body['phone']?.toString() ?? '';
        if (!phone.startsWith('+') || phone.length < 8) {
          return _DemoResponse(422, {'message': 'Invalid phone number'});
        }
        return _DemoResponse(200, {'sent': true});

      case 'POST /auth/verify':
        if (body['token']?.toString() != demoOtp) {
          return _DemoResponse(401, {'message': 'That code is not right'});
        }
        _signedIn = true;
        return _DemoResponse(200, {
          'user': {'id': 'demo-user', 'phone': body['phone']},
        });

      case 'POST /auth/signout':
        _signedIn = false;
        return _DemoResponse(200, {'signed_out': true});

      case 'GET /profile':
        if (!_signedIn) return _DemoResponse(401, {'message': 'Not signed in'});
        return _DemoResponse(200, {
          'id': 'demo-user',
          'full_name': 'Demo User',
          'role': 'user',
          'location_label': 'Home',
          'address': 'Diya Green City, Rajnagar Extension',
        });

      case 'PATCH /profile':
        if (!_signedIn) return _DemoResponse(401, {'message': 'Not signed in'});
        return _DemoResponse(200, body);

      case 'GET /bookings':
        return _DemoResponse(200, List<Map<String, dynamic>>.from(_bookings));

      case 'POST /bookings':
        // Stamped with a server-side id, as a real backend would.
        final stored = {
          ...body,
          'id': 'demo-${DateTime.now().microsecondsSinceEpoch}',
        };
        _bookings.insert(0, stored);
        return _DemoResponse(201, stored);

      case 'GET /favourites':
        return _DemoResponse(200, {
          'property': _favouriteProperties.toList(),
          'restaurant': _favouriteRestaurants.toList(),
        });

      case 'POST /favourites':
        _setFor(body['item_type']?.toString()).add(body['item_id'].toString());
        return _DemoResponse(201, body);

      case 'DELETE /favourites':
        _setFor(body['item_type']?.toString())
            .remove(body['item_id'].toString());
        return _DemoResponse(204, null);
    }
    return null;
  }

  Set<String> _setFor(String? type) =>
      type == 'restaurant' ? _favouriteRestaurants : _favouriteProperties;
}

class _DemoResponse {
  const _DemoResponse(this.status, this.body);
  final int status;
  final Object? body;
}
