part of 'cart_bloc.dart';

sealed class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => const [];
}

/// Adding from a different restaurant replaces the cart, as the UI warns.
final class CartItemAdded extends CartEvent {
  const CartItemAdded(this.item, this.restaurant);
  final MenuItem item;
  final Restaurant restaurant;

  @override
  List<Object?> get props => [item.id, restaurant.id];
}

final class CartItemRemoved extends CartEvent {
  const CartItemRemoved(this.item);
  final MenuItem item;

  @override
  List<Object?> get props => [item.id];
}

/// Tapping the applied coupon again clears it.
final class CartCouponToggled extends CartEvent {
  const CartCouponToggled(this.coupon);
  final Coupon? coupon;

  @override
  List<Object?> get props => [coupon?.code];
}

final class CartInstructionToggled extends CartEvent {
  const CartInstructionToggled(this.instruction);
  final String instruction;

  @override
  List<Object?> get props => [instruction];
}

final class CartCleared extends CartEvent {
  const CartCleared();
}
