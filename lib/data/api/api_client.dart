import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'api_service.dart';
import 'demo_backend.dart';

/// The app's HTTP client.
///
/// `ApiClient.demo()` attaches [DemoBackend], which answers every request
/// in-process. `ApiClient.live()` points at a real server instead. Nothing
/// above this class knows which it is holding.
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

  /// The generated Retrofit client. The repositories move onto this next;
  /// the hand-written helpers below go once they have.
  final ApiService service;

  /// GETs a JSON array. Returns an empty list rather than throwing when the
  /// body is not the shape expected, so one odd endpoint cannot take down a
  /// whole screen.
  Future<List<Map<String, dynamic>>> getList(String path) async {
    final response = await dio.get<dynamic>(path);
    final data = response.data;
    if (data is! List) return const [];
    return [
      for (final row in data)
        if (row is Map) Map<String, dynamic>.from(row),
    ];
  }

  Future<Map<String, dynamic>?> getObject(String path) async {
    final response = await dio.get<dynamic>(path);
    final data = response.data;
    return data is Map ? Map<String, dynamic>.from(data) : null;
  }

  Future<Map<String, dynamic>?> post(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final response = await dio.post<dynamic>(path, data: body);
    final data = response.data;
    return data is Map ? Map<String, dynamic>.from(data) : null;
  }

  Future<void> delete(String path, {Map<String, dynamic>? body}) =>
      dio.delete<dynamic>(path, data: body);

  Future<Map<String, dynamic>?> patch(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final response = await dio.patch<dynamic>(path, data: body);
    final data = response.data;
    return data is Map ? Map<String, dynamic>.from(data) : null;
  }

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
