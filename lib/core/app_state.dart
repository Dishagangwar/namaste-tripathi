import 'package:flutter/foundation.dart';
import '../data/models.dart';
import '../data/mock_data.dart';
import '../data/remote/auth_repository.dart';
import '../data/remote/bookings_repository.dart';
import '../data/remote/favourites_repository.dart';
import '../data/remote/supabase_service.dart';

enum JoinRole { user, provider }

class SessionState extends ChangeNotifier {
  SessionState({this.auth = const AuthRepository()});

  final AuthRepository auth;


  String phone = '';
  String countryCode = '+91';
  JoinRole role = JoinRole.user;
  String location = 'Home';
  String address = 'Diya Green City, Rajnagar Extension';
  String name = 'Darsh';

  /// True when this device holds a real Supabase session.
  bool get isSignedIn => SupabaseService.isSignedIn;

  String? get userId => SupabaseService.currentUser?.id;

  /// E.164 number of the signed-in user, falling back to what was typed.
  String get e164Phone => auth.formatPhone(countryCode, phone);

  void setPhone(String value) {
    phone = value;
    notifyListeners();
  }

  void setCountryCode(String value) {
    countryCode = value;
    notifyListeners();
  }

  void setRole(JoinRole value) {
    role = value;
    notifyListeners();
    auth.saveProfile(role: value.name);
  }

  void setLocation(String label, String addr) {
    location = label;
    address = addr;
    notifyListeners();
    auth.saveProfile(locationLabel: label, address: addr);
  }

  void setName(String value) {
    name = value;
    notifyListeners();
    auth.saveProfile(fullName: value);
  }

  /// Pulls the profile row written at sign-up so a returning user sees their
  /// own name, role and saved address instead of the defaults.
  Future<void> loadProfile() async {
    final row = await auth.fetchProfile();
    if (row == null) return;
    final remotePhone = row['phone']?.toString() ?? '';
    final fullName = row['full_name']?.toString() ?? '';
    final remoteRole = row['role']?.toString() ?? '';
    final label = row['location_label']?.toString() ?? '';
    final addr = row['address']?.toString() ?? '';
    if (remotePhone.isNotEmpty) phone = remotePhone;
    if (fullName.isNotEmpty) name = fullName;
    if (remoteRole == 'provider') role = JoinRole.provider;
    if (remoteRole == 'user') role = JoinRole.user;
    if (label.isNotEmpty) location = label;
    if (addr.isNotEmpty) address = addr;
    notifyListeners();
  }

  Future<void> signOut() async {
    await auth.signOut();
    notifyListeners();
  }
}

class CartState extends ChangeNotifier {
  final List<CartLine> lines = [];
  Restaurant? restaurant;
  Coupon? coupon;
  final Set<String> instructions = {};

  bool get isEmpty => lines.isEmpty;
  int get itemCount => lines.fold(0, (sum, l) => sum + l.quantity);
  double get subtotal => lines.fold(0.0, (sum, l) => sum + l.total);

  double get deliveryFee {
    if (lines.isEmpty) return 0;
    if (coupon?.code == 'FREEDEL' && subtotal >= coupon!.minOrder) return 0;
    return 50;
  }

  double get taxes => lines.isEmpty ? 0 : (subtotal * 0.09).roundToDouble();
  double get discount => coupon?.discountOn(subtotal) ?? 0;
  double get total => (subtotal + deliveryFee + taxes - discount)
      .clamp(0, double.infinity)
      .toDouble();

  int quantityOf(MenuItem item) {
    for (final l in lines) {
      if (l.item.id == item.id) return l.quantity;
    }
    return 0;
  }

  void add(MenuItem item, Restaurant from) {
    if (restaurant != null && restaurant!.id != from.id) {
      lines.clear();
      coupon = null;
    }
    restaurant = from;
    final existing = lines.where((l) => l.item.id == item.id).toList();
    if (existing.isEmpty) {
      lines.add(CartLine(item, 1));
    } else {
      existing.first.quantity++;
    }
    notifyListeners();
  }

  void remove(MenuItem item) {
    for (var i = 0; i < lines.length; i++) {
      if (lines[i].item.id == item.id) {
        lines[i].quantity--;
        if (lines[i].quantity <= 0) lines.removeAt(i);
        break;
      }
    }
    if (lines.isEmpty) {
      restaurant = null;
      coupon = null;
    }
    notifyListeners();
  }

  void applyCoupon(Coupon? value) {
    coupon = (coupon?.code == value?.code) ? null : value;
    notifyListeners();
  }

  void toggleInstruction(String value) {
    instructions.contains(value)
        ? instructions.remove(value)
        : instructions.add(value);
    notifyListeners();
  }

  void clear() {
    lines.clear();
    restaurant = null;
    coupon = null;
    instructions.clear();
    notifyListeners();
  }
}

class FavouritesState extends ChangeNotifier {
  FavouritesState({this.repository = const FavouritesRepository()});

  final FavouritesRepository repository;


  /// Pre-seeded so the app has something to show before sign-in; replaced
  /// wholesale by the user's own rows once Supabase answers.
  final Set<String> propertyIds = {'pr6', 'pr4', 'pr2'};
  final Set<String> restaurantIds = {'r1'};

  bool isPropertyFavourite(String id) => propertyIds.contains(id);
  bool isRestaurantSaved(String id) => restaurantIds.contains(id);

  /// Replaces the local sets with the signed-in user's saved items.
  Future<void> load() async {
    final grouped = await repository.fetch();
    if (grouped == null) return;
    propertyIds
      ..clear()
      ..addAll(grouped[FavouritesRepository.propertyType] ?? const <String>{});
    restaurantIds
      ..clear()
      ..addAll(grouped[FavouritesRepository.restaurantType] ?? const <String>{});
    notifyListeners();
  }

  void toggleProperty(String id) {
    final added = !propertyIds.contains(id);
    added ? propertyIds.add(id) : propertyIds.remove(id);
    notifyListeners();
    _sync(FavouritesRepository.propertyType, id, added);
  }

  void toggleRestaurant(String id) {
    final added = !restaurantIds.contains(id);
    added ? restaurantIds.add(id) : restaurantIds.remove(id);
    notifyListeners();
    _sync(FavouritesRepository.restaurantType, id, added);
  }

  /// Fire-and-forget: the tap has already been reflected on screen, so a
  /// failed write is logged rather than bounced back at the user.
  void _sync(String type, String id, bool added) {
    added ? repository.add(type, id) : repository.remove(type, id);
  }
}

class BookingsState extends ChangeNotifier {
  BookingsState({this.repository = const BookingsRepository()});

  final BookingsRepository repository;


  /// The sample itinerary, shown until the user's own bookings load.
  final List<Booking> items = [...kBookings];

  bool _loading = false;

  bool get isLoading => _loading;

  /// Swaps the sample itinerary for the signed-in user's real bookings.
  Future<void> load() async {
    if (_loading) return;
    _loading = true;
    notifyListeners();
    try {
      final remote = await repository.fetch();
      if (remote != null) {
        items
          ..clear()
          ..addAll(remote);
      }
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Shows the booking straight away, then replaces it with the stored row
  /// so it carries the database id.
  void add(Booking booking) {
    items.insert(0, booking);
    notifyListeners();
    _persist(booking);
  }

  Future<void> _persist(Booking booking) async {
    final stored = await repository.add(booking);
    if (stored == null) return;
    final index = items.indexWhere((b) => b.id == booking.id);
    if (index == -1) return;
    items[index] = stored;
    notifyListeners();
  }
}
