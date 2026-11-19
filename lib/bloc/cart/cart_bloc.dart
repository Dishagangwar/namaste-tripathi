import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../data/models.dart';

part 'cart_event.dart';
part 'cart_state.dart';

/// The food basket. Purely local -- an order only reaches Supabase when it
/// is placed, as a booking.
class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(const CartState()) {
    on<CartItemAdded>(_onItemAdded);
    on<CartItemRemoved>(_onItemRemoved);
    on<CartCouponToggled>(_onCouponToggled);
    on<CartInstructionToggled>(_onInstructionToggled);
    on<CartCleared>(_onCleared);
  }

  void _onItemAdded(CartItemAdded event, Emitter<CartState> emit) {
    // A basket holds one restaurant at a time; switching starts over.
    final switching = state.restaurant != null &&
        state.restaurant!.id != event.restaurant.id;
    final lines = switching ? <CartLine>[] : [...state.lines];

    final index = lines.indexWhere((l) => l.item.id == event.item.id);
    if (index == -1) {
      lines.add(CartLine(event.item, 1));
    } else {
      lines[index] = lines[index].copyWith(quantity: lines[index].quantity + 1);
    }

    emit(state.copyWith(
      lines: lines,
      restaurant: event.restaurant,
      clearCoupon: switching,
    ));
  }

  void _onItemRemoved(CartItemRemoved event, Emitter<CartState> emit) {
    final lines = [...state.lines];
    final index = lines.indexWhere((l) => l.item.id == event.item.id);
    if (index == -1) return;

    final remaining = lines[index].quantity - 1;
    if (remaining <= 0) {
      lines.removeAt(index);
    } else {
      lines[index] = lines[index].copyWith(quantity: remaining);
    }

    // Emptying the basket also drops the restaurant and coupon, so the next
    // add starts clean.
    if (lines.isEmpty) {
      emit(const CartState());
      return;
    }
    emit(state.copyWith(lines: lines));
  }

  void _onCouponToggled(CartCouponToggled event, Emitter<CartState> emit) {
    final same = state.coupon?.code == event.coupon?.code;
    emit(state.copyWith(coupon: same ? null : event.coupon, clearCoupon: same));
  }

  void _onInstructionToggled(
    CartInstructionToggled event,
    Emitter<CartState> emit,
  ) {
    final next = {...state.instructions};
    next.contains(event.instruction)
        ? next.remove(event.instruction)
        : next.add(event.instruction);
    emit(state.copyWith(instructions: next));
  }

  void _onCleared(CartCleared event, Emitter<CartState> emit) {
    emit(const CartState());
  }
}
