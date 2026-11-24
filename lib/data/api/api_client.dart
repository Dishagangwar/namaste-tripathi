import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'api_service.dart';
import 'demo_backend.dart';

/// Owns the Dio instance and the Retrofit client built on it.
///
/// `ApiClient.demo()` attaches [DemoBackend], which answers every request
/// in-process. `ApiClient.live()` points at a real server instead. Nothing
/// above this class knows which it is holding -- the repositories only ever
/// see [service].
class ApiClient {
  /// [service] is injectable so tests can drive the repositories through a
  /// mocked API without standing up Dio, an interceptor and a wire format
  /// just to make one call fail.
  ApiClient(this.dio, {ApiService? service})
      : service = service ?? ApiService(dio);

  /// Everything served by the in-app backend. The host is never resolved,
  /// but a real-looking base URL keeps logs and errors readable.
  factory ApiClient.demo({
    Duration latency = const Duration(milliseconds: 400),
    double failureRate = 0,
  }) {
    final dio = Dio(BaseOptions(
      baseUrl: 'https://demo.namastetripathi.local',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));
    dio.interceptors.add(
      DemoBackend(latency: latency, failureRate: failureRate),
    );
    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(requestBody: false));
    }
    return ApiClient(dio);
  }

  factory ApiClient.live(String baseUrl) => ApiClient(
        Dio(BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        )),
      );

  final Dio dio;

  /// The generated Retrofit client. Every call the app makes goes through
  /// this; the paths live in `api_service.dart`, not at the call sites.
  final ApiService service;

  /// Turns a Dio failure into something worth showing a user. The server's
  /// own message wins when it sent one.
  static String describeError(Object error) {
    if (error is! DioException) return 'Something went wrong.';
    final body = error.response?.data;
    if (body is Map && body['message'] != null) {
      return body['message'].toString();
    }
    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.sendTimeout =>
        'The server took too long to answer.',
      DioExceptionType.connectionError => 'Could not reach the server.',
      _ => 'Something went wrong.',
    };
  }
}
