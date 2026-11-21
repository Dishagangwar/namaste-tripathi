import 'package:flutter/foundation.dart';

import 'api/api_client.dart';
import 'api/api_repositories.dart';
import 'remote/auth_repository.dart';
import 'remote/bookings_repository.dart';
import 'remote/catalog_repository.dart';
import 'remote/config_repository.dart';
import 'remote/favourites_repository.dart';
import 'remote/orders_repository.dart';
import 'remote/rides_repository.dart';
import 'remote/supabase_service.dart';
import 'repositories.dart';

enum BackendMode {
  /// The in-app demo backend: dio talking to [DemoBackend], no network.
  demo,

  /// The real Supabase project.
  supabase,
}

/// Picks which set of repositories the app runs on.
///
/// Chosen at build time:
///
///   flutter run --dart-define=BACKEND=demo
///
/// With no flag the app uses Supabase when a key was compiled in, and the
/// demo backend otherwise -- so a checkout with no credentials still has a
/// working, writable backend rather than a read-only bundled catalogue.
class Backend {
  const Backend._();

  static const _flag = String.fromEnvironment('BACKEND');

  static BackendMode? _override;

  /// Lets tests and the demo switcher change backends at runtime.
  @visibleForTesting
  static set mode(BackendMode value) => _override = value;

  static BackendMode get mode {
    if (_override != null) return _override!;
    return switch (_flag.toLowerCase()) {
      'demo' => BackendMode.demo,
      'supabase' => BackendMode.supabase,
      _ => SupabaseService.isReady ? BackendMode.supabase : BackendMode.demo,
    };
  }

  static bool get isDemo => mode == BackendMode.demo;

  /// One client for the process, so the demo backend's mutable state (the
  /// bookings you add, the favourites you toggle) survives between screens.
  static ApiClient? _client;

  static ApiClient get client => _client ??= ApiClient.demo();

  /// Swaps in a different client, for tests or a tweaked demo (latency,
  /// injected failures).
  @visibleForTesting
  static set client(ApiClient value) => _client = value;

  static CatalogSource catalog() =>
      isDemo ? ApiCatalogRepository(client) : const CatalogRepository();

  static BookingsSource bookings() =>
      isDemo ? ApiBookingsRepository(client) : const BookingsRepository();

  static FavouritesSource favourites() =>
      isDemo ? ApiFavouritesRepository(client) : const FavouritesRepository();

  static AuthSource auth() =>
      isDemo ? ApiAuthRepository(client) : const AuthRepository();

  static ConfigSource config() =>
      isDemo ? ApiConfigRepository(client) : const ConfigRepository();

  static OrdersSource orders() =>
      isDemo ? ApiOrdersRepository(client) : const OrdersRepository();

  static RidesSource rides() =>
      isDemo ? ApiRidesRepository(client) : const RidesRepository();

  /// Drops cached state so a later call rebuilds against the current mode.
  @visibleForTesting
  static void reset() {
    _override = null;
    _client = null;
  }
}
