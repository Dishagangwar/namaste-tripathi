import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_service.dart';

/// The phone-OTP sign-in flow, plus the profile row that belongs to it.
///
/// Supabase needs an SMS provider configured under Authentication > Providers
/// > Phone for live codes. Until one is set up, add the number under
/// Authentication > Users as a test phone with a fixed OTP, or the app's
/// `demoMode` path lets the UI through without a server round-trip.
class AuthRepository {
  const AuthRepository();

  /// True when codes can actually be sent. When false the auth screens stay
  /// usable and simply skip verification.
  bool get isLive => SupabaseService.isReady;

  User? get currentUser => SupabaseService.currentUser;

  Stream<AuthState> get onAuthStateChange =>
      SupabaseService.client.auth.onAuthStateChange;

  /// E.164, which is the only format Supabase accepts: `+919876543210`.
  String formatPhone(String countryCode, String number) {
    final digits = number.replaceAll(RegExp(r'\D'), '');
    final code = countryCode.replaceAll(RegExp(r'[^\d+]'), '');
    return code.startsWith('+') ? '$code$digits' : '+$code$digits';
  }

  /// Sends the SMS code. Returns null on success, or a message to show.
  Future<String?> sendOtp({
    required String countryCode,
    required String phone,
  }) async {
    if (!isLive) return null;
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
  Future<String?> verifyOtp({
    required String countryCode,
    required String phone,
    required String token,
  }) async {
    if (!isLive) return null;
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

  Future<void> signOut() async {
    if (!isLive) return;
    try {
      await SupabaseService.client.auth.signOut();
    } catch (error) {
      debugPrint('Supabase: signOut failed — $error');
    }
  }
}
