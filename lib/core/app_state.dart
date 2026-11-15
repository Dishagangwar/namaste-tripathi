import 'package:flutter/foundation.dart';
import '../data/models.dart';
import '../data/mock_data.dart';

enum JoinRole { user, provider }

class SessionState extends ChangeNotifier {
  String phone = '';
  String countryCode = '+91';
  JoinRole role = JoinRole.user;
  String location = 'Home';
  String address = 'Diya Green City, Rajnagar Extension';
  String name = 'Darsh';

  void setPhone(String value) {
    phone = value;
    notifyListeners();
  }

  void setRole(JoinRole value) {
    role = value;
    notifyListeners();
  }

  void setLocation(String label, String addr) {
    location = label;
    address = addr;
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
  final Set<String> propertyIds = {'pr6', 'pr4', 'pr2'};
  final Set<String> restaurantIds = {'r1'};

  bool isPropertyFavourite(String id) => propertyIds.contains(id);
  bool isRestaurantSaved(String id) => restaurantIds.contains(id);

  void toggleProperty(String id) {
    propertyIds.contains(id) ? propertyIds.remove(id) : propertyIds.add(id);
    notifyListeners();
  }

  void toggleRestaurant(String id) {
    restaurantIds.contains(id)
        ? restaurantIds.remove(id)
        : restaurantIds.add(id);
    notifyListeners();
  }
}

class BookingsState extends ChangeNotifier {
  final List<Booking> items = [...kBookings];

  void add(Booking booking) {
    items.insert(0, booking);
    notifyListeners();
  }
}
