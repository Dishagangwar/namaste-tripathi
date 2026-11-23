/// Supabase connection settings.
///
/// The project URL is public and lives here. The key is read from the build
/// environment so nothing key-shaped is committed:
///
///   flutter run --dart-define=SUPABASE_PUBLISHABLE_KEY=sb_publishable_...
///
/// `SUPABASE_ANON_KEY` is accepted as well for projects still on a legacy
/// anon JWT. In VS Code put the flag in `.vscode/launch.json` under
/// `toolArgs`; in Android Studio under Run > Edit Configurations >
/// Additional run args; in CI read it from a secret.
class SupabaseConfig {
  const SupabaseConfig._();

  static const url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://cwfozayeingrqomplcgg.supabase.co',
  );

  static const _publishableKey =
      String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');
  static const _anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  /// The publishable (anon) key this build was compiled with, or '' if none.
  static String get key =>
      _publishableKey.isNotEmpty ? _publishableKey : _anonKey;

  /// False when the app was built without a usable key. Every repository
  /// falls back to the bundled catalogue in that case, so the UI still runs.
  ///
  /// A key has to actually look like one: the checked-in launch config holds
  /// a `PASTE_YOUR_...` placeholder, and treating that as real would leave a
  /// developer stuck on the sign-in screen with a 401 instead of walking
  /// through the app on bundled data.
  static bool get isConfigured => url.isNotEmpty && _looksLikeKey(key);

  /// Publishable keys start with `sb_publishable_`; legacy anon keys are JWTs,
  /// which always start with the base64 of `{"alg"`.
  static bool _looksLikeKey(String value) =>
      value.startsWith('sb_publishable_') || value.startsWith('eyJ');

  /// What this build actually received, for the debug badge.
  ///
  /// "no key" and "a key that did not work" are different problems with very
  /// different fixes, and the app was reporting them with the same sentence.
  /// The key is publishable -- it ships in every copy of the app -- so a
  /// prefix is safe to show, and seeing it is the quickest proof that the
  /// dart-define reached the build at all.
  static String get diagnosis {
    if (key.isEmpty) {
      return 'no SUPABASE_PUBLISHABLE_KEY was passed to this build';
    }
    if (!_looksLikeKey(key)) {
      return 'SUPABASE_PUBLISHABLE_KEY is set but malformed: '
          '"${key.length > 12 ? '${key.substring(0, 12)}…' : key}"';
    }
    return 'key ${key.substring(0, 18)}… compiled in';
  }
}
