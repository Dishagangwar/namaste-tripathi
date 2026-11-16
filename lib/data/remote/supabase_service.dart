import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/supabase_config.dart';

/// Owns the single Supabase client for the app.
///
/// `initialize` never throws: if the project is unreachable or the build has
/// no anon key, [isReady] stays false and the repositories serve the bundled
/// catalogue instead of leaving the user on a dead screen.
class SupabaseService {
  const SupabaseService._();

  static bool _ready = false;

  static bool get isReady => _ready;

  static SupabaseClient get client => Supabase.instance.client;

  /// The signed-in user, or null when running offline / unauthenticated.
  static User? get currentUser => _ready ? client.auth.currentUser : null;

  static bool get isSignedIn => currentUser != null;

  static Future<void> initialize() async {
    if (!SupabaseConfig.isConfigured) {
      debugPrint(
        'Supabase: no key in this build — running on bundled data. Pass '
        '--dart-define=SUPABASE_PUBLISHABLE_KEY=... to connect.',
      );
      return;
    }
    try {
      await Supabase.initialize(
        url: SupabaseConfig.url,
        publishableKey: SupabaseConfig.key,
        authOptions: const FlutterAuthClientOptions(
          authFlowType: AuthFlowType.pkce,
        ),
      );
      _ready = true;
    } catch (error, stack) {
      debugPrint('Supabase: initialize failed — $error');
      debugPrintStack(stackTrace: stack);
    }
  }
}
