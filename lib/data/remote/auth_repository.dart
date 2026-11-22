import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/google_auth_config.dart';
import '../repositories.dart';
import 'supabase_service.dart';

/// Real sign-in against Supabase: Google through the native account picker,
/// and phone OTP where an SMS provider is configured.
///
/// Phone codes need a provider under Authentication > Providers > Phone.
/// Until one is set up, add the number under Authentication > Users as a test
/// phone with a fixed OTP. Google needs the provider enabled with the Web
/// client ID and secret, and the Android/iOS client IDs listed as authorized.
class AuthRepository implements AuthSource {
  const AuthRepository();

  /// Shown when the build itself cannot authenticate -- no key compiled in,
  /// or no Google client ID. It is a message rather than a silent success so
  /// the app cannot walk into the shell with no session behind it.
  static const _notConfigured =
      'This build has no Supabase key, so it cannot sign you in.';

  /// Google's SDK only wants initialising once per process.
  static bool _googleReady = false;

  /// True when codes can actually be sent.
  bool get isLive => SupabaseService.isReady;

  User? get currentUser => SupabaseService.currentUser;

  @override
  bool get isSignedIn => SupabaseService.isSignedIn;

  Stream<AuthState> get onAuthStateChange =>
      SupabaseService.client.auth.onAuthStateChange;

  /// E.164, which is the only format Supabase accepts: `+919876543210`.
  @override
  String formatPhone(String countryCode, String number) {
    final digits = number.replaceAll(RegExp(r'\D'), '');
    final code = countryCode.replaceAll(RegExp(r'[^\d+]'), '');
    return code.startsWith('+') ? '$code$digits' : '+$code$digits';
  }

  /// Sends the SMS code. Returns null on success, or a message to show.
  @override
  Future<String?> sendOtp({
    required String countryCode,
    required String phone,
  }) async {
    // Returning null here would mean success, which is how a build with no
    // key once walked straight into the app with no session behind it and
    // then dropped every write in silence.
    if (!isLive) return _notConfigured;
    try {
      await SupabaseService.client.auth.signInWithOtp(
        phone: formatPhone(countryCode, phone),
      );
      return null;
    } on AuthException catch (error) {
      debugPrint('Supabase: sendOtp failed — ${error.message}');
      return error.message;
    } catch (error) {
      debugPrint('Supabase: sendOtp failed — $error');
      return 'Could not send the code. Please try again.';
    }
  }

  /// Verifies the code. Returns null on success, or a message to show.
  @override
  Future<String?> verifyOtp({
    required String countryCode,
    required String phone,
    required String token,
  }) async {
    if (!isLive) return _notConfigured;
    try {
      await SupabaseService.client.auth.verifyOTP(
        type: OtpType.sms,
        phone: formatPhone(countryCode, phone),
        token: token,
      );
      return null;
    } on AuthException catch (error) {
      debugPrint('Supabase: verifyOtp failed — ${error.message}');
      return error.message;
    } catch (error) {
      debugPrint('Supabase: verifyOtp failed — $error');
      return 'Could not verify that code. Please try again.';
    }
  }

  /// Reads the signed-in user's profile row, or null when there is none.
  @override
  Future<Map<String, dynamic>?> fetchProfile() async {
    final user = currentUser;
    if (user == null) return null;
    try {
      final row = await SupabaseService.client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();
      return row;
    } catch (error) {
      debugPrint('Supabase: fetchProfile failed — $error');
      return null;
    }
  }

  /// Writes the fields the app owns. Silently no-ops when signed out.
  @override
  Future<void> saveProfile({
    String? fullName,
    String? role,
    String? locationLabel,
    String? address,
  }) async {
    final user = currentUser;
    if (user == null) return;
    final payload = <String, dynamic>{
      'id': user.id,
      if (user.phone != null && user.phone!.isNotEmpty) 'phone': user.phone,
      'full_name': ?fullName,
      'role': ?role,
      'location_label': ?locationLabel,
      'address': ?address,
    };
    try {
      await SupabaseService.client.from('profiles').upsert(payload);
    } catch (error) {
      debugPrint('Supabase: saveProfile failed — $error');
    }
  }

  /// Signs in with Google and exchanges the identity token for a Supabase
  /// session.
  ///
  /// This is the native flow, not a browser redirect: Google's own account
  /// sheet appears, so there is no deep link to configure and nothing leaves
  /// the app. The identity token it returns is minted for the Web client ID
  /// (see [GoogleAuthConfig]), which is the audience Supabase validates.
  @override
  Future<SignInResult> signInWithGoogle() async {
    if (!isLive) return SignInResult.failed(_notConfigured);
    if (!GoogleAuthConfig.isConfigured) {
      return SignInResult.failed(
        'Google sign-in is not configured in this build.',
      );
    }

    try {
      final google = GoogleSignIn.instance;
      if (!_googleReady) {
        await google.initialize(
          // iOS reads its own client ID; Android matches by package name and
          // signing certificate, so it passes none.
          clientId: GoogleAuthConfig.iosClientIdOrNull,
          serverClientId: GoogleAuthConfig.serverClientIdOrNull,
        );
        _googleReady = true;
      }

      final account = await google.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null) {
        return SignInResult.failed(
          'Google did not return an identity token. Check that the Web '
          'client ID is the one set as serverClientId.',
        );
      }

      // Supabase takes the access token too when one is available; it is not
      // required, so a null here is not an error.
      final authorization = await account.authorizationClient
          .authorizationForScopes(const ['email', 'profile']);

      await SupabaseService.client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: authorization?.accessToken,
      );

      // The profiles row is created by the sign-up trigger; this fills in the
      // name Google gave us, which the trigger cannot know.
      final name = account.displayName;
      if (name != null && name.isNotEmpty) {
        await saveProfile(fullName: name);
      }

      return SignInResult.signedIn;
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) {
        return SignInResult.cancelled;
      }
      debugPrint('Google: sign-in failed — ${error.code} ${error.description}');
      return SignInResult.failed(switch (error.code) {
        // Worth naming precisely: these two are what a half-finished console
        // setup looks like from inside the app.
        GoogleSignInExceptionCode.clientConfigurationError =>
          'This app is not registered for Google sign-in. Check the Android '
              'package name and SHA-1, or the iOS client ID.',
        GoogleSignInExceptionCode.providerConfigurationError =>
          'Google Play services is unavailable or out of date on this device.',
        _ => 'Could not sign in with Google. Please try again.',
      });
    } on AuthException catch (error) {
      debugPrint('Supabase: signInWithIdToken failed — ${error.message}');
      return SignInResult.failed(error.message);
    } catch (error) {
      debugPrint('Google: sign-in failed — $error');
      return SignInResult.failed('Could not sign in with Google.');
    }
  }

  @override
  Future<void> signOut() async {
    if (!isLive) return;
    // Google is signed out too, or its account sheet would skip straight past
    // the picker on the next attempt and silently reuse the old account.
    try {
      await GoogleSignIn.instance.signOut();
    } catch (error) {
      debugPrint('Google: signOut failed — $error');
    }
    try {
      await SupabaseService.client.auth.signOut();
    } catch (error) {
      debugPrint('Supabase: signOut failed — $error');
    }
  }
}
