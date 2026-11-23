import 'models.dart';
import 'remote/catalog_repository.dart' show CatalogData;

export 'remote/catalog_repository.dart' show CatalogData;

/// What the blocs depend on, so neither transport is baked into them.
///
/// Two implementations exist: the Supabase ones in `remote/`, and the HTTP
/// ones in `api/` that talk to the demo backend.

abstract interface class CatalogSource {
  Future<CatalogData> fetch();
}

abstract interface class BookingsSource {
  /// Null means there was nothing to read from -- keep what is on screen.
  Future<List<Booking>?> fetch();
  Future<Booking?> add(Booking booking);
}

abstract interface class FavouritesSource {
  static const propertyType = 'property';
  static const restaurantType = 'restaurant';

  Future<Map<String, Set<String>>?> fetch();
  Future<void> add(String itemType, String itemId);
  Future<void> remove(String itemType, String itemId);
}

/// How a provider sign-in ended.
///
/// Cancelling is deliberately not a failure. The user tapped the Google
/// button, saw the account sheet and backed out; showing them an error for
/// changing their mind would be wrong, so the UI needs to tell the two apart.
enum SignInOutcome { signedIn, cancelled, failed }

class SignInResult {
  const SignInResult(this.outcome, {this.message, this.isDemo = false});

  final SignInOutcome outcome;

  /// Set only when [outcome] is [SignInOutcome.failed].
  final String? message;

  /// True when no real provider was involved and the session came from the
  /// in-app demo backend.
  ///
  /// This exists because a fake sign-in that looks identical to a real one
  /// is how an afternoon gets lost: the Google button appeared to work, went
  /// straight to the next screen, and nothing had authenticated.
  final bool isDemo;

  static const signedIn = SignInResult(SignInOutcome.signedIn);
  static const demoSignedIn =
      SignInResult(SignInOutcome.signedIn, isDemo: true);
  static const cancelled = SignInResult(SignInOutcome.cancelled);

  factory SignInResult.failed(String message) =>
      SignInResult(SignInOutcome.failed, message: message);

  bool get isSignedIn => outcome == SignInOutcome.signedIn;
  bool get isCancelled => outcome == SignInOutcome.cancelled;
}

abstract interface class AuthSource {
  bool get isSignedIn;

  String formatPhone(String countryCode, String number);

  /// Signs in with Google, through the native account picker.
  Future<SignInResult> signInWithGoogle();

  /// Null on success, or a message to show the user.
  Future<String?> sendOtp({required String countryCode, required String phone});

  Future<String?> verifyOtp({
    required String countryCode,
    required String phone,
    required String token,
  });

  Future<Map<String, dynamic>?> fetchProfile();

  Future<void> saveProfile({
    String? fullName,
    String? role,
    String? locationLabel,
    String? address,
  });

  Future<void> signOut();
}

/// The service tiles, filter chips, saved addresses, ride classes and
/// editorial copy. Null means fall back to the bundled taxonomy.
abstract interface class ConfigSource {
  Future<AppConfig?> fetch();
}

abstract interface class OrdersSource {
  /// Null means there was nothing to read from -- keep what is on screen.
  Future<List<FoodOrder>?> fetch();

  /// Returns the stored order, carrying the id and reference the server
  /// assigned, or null when it could not be saved.
  Future<FoodOrder?> place(FoodOrder order);
}

abstract interface class RidesSource {
  Future<List<Ride>?> fetch();
  Future<Ride?> book(Ride ride);
}
