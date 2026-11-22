/// Google sign-in client IDs.
///
/// These are not secrets -- a client ID ships inside every copy of the app --
/// but they are per-project configuration, so they are read from the build
/// environment alongside the Supabase key rather than committed:
///
///   flutter run \
///     --dart-define=SUPABASE_PUBLISHABLE_KEY=sb_publishable_... \
///     --dart-define=GOOGLE_SERVER_CLIENT_ID=....apps.googleusercontent.com \
///     --dart-define=GOOGLE_IOS_CLIENT_ID=....apps.googleusercontent.com
///
/// There are three client IDs in a Google Cloud project and it matters which
/// goes where:
///
///  * The **Web** client ID is [serverClientId]. Android passes it so that the
///    identity token is issued *for your backend*, and Supabase checks that
///    audience when it validates the token. Without it the token is minted for
///    the Android app and Supabase rejects it.
///  * The **iOS** client ID is [iosClientId], and its reversed form also has to
///    be a URL scheme in `ios/Runner/Info.plist`.
///  * The **Android** client ID is never named here. It is matched by package
///    name and signing certificate, so it only has to exist in Google Cloud.
class GoogleAuthConfig {
  const GoogleAuthConfig._();

  static const serverClientId =
      String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID');

  static const iosClientId = String.fromEnvironment('GOOGLE_IOS_CLIENT_ID');

  /// A client ID looks like `<digits>-<hash>.apps.googleusercontent.com`.
  /// Checking the shape stops a placeholder from being treated as real, the
  /// way [SupabaseConfig] guards its key.
  static bool _looksLikeClientId(String value) =>
      value.endsWith('.apps.googleusercontent.com');

  /// False when this build has no usable Web client ID, in which case Google
  /// sign-in is reported as unconfigured instead of failing deep inside the
  /// platform SDK with an opaque message.
  static bool get isConfigured => _looksLikeClientId(serverClientId);

  static String? get serverClientIdOrNull =>
      _looksLikeClientId(serverClientId) ? serverClientId : null;

  static String? get iosClientIdOrNull =>
      _looksLikeClientId(iosClientId) ? iosClientId : null;
}
