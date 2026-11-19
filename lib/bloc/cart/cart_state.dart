part of 'cart_bloc.dart';

/// The basket, plus the bill maths derived from it.
///
/// The totals are getters rather than stored fields so they can never drift
/// out of step with the lines they are computed from.
final class CartState extends Equatable {
  const CartState({
    this.lines = const [],
    this.restaurant,
    this.coupon,
    this.instructions = const {},
  });

  final List<CartLine> lines;
  final Restaurant? restaurant;
  final Coupon? coupon;
  final Set<String> instructions;

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

  CartState copyWith({
    List<CartLine>? lines,
    Restaurant? restaurant,
    Coupon? coupon,
    Set<String>? instructions,
    bool clearRestaurant = false,
    bool clearCoupon = false,
  }) =>
      CartState(
        lines: lines ?? this.lines,
        restaurant: clearRestaurant ? null : (restaurant ?? this.restaurant),
        coupon: clearCoupon ? null : (coupon ?? this.coupon),
        instructions: instructions ?? this.instructions,
      );

  @override
  List<Object?> get props => [lines, restaurant?.id, coupon?.code, instructions];
}
