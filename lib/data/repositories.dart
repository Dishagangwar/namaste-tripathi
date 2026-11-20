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

abstract interface class AuthSource {
  bool get isSignedIn;

  String formatPhone(String countryCode, String number);

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
