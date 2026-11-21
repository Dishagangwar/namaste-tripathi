part of 'orders_bloc.dart';

sealed class OrdersEvent extends Equatable {
  const OrdersEvent();

  @override
  List<Object?> get props => const [];
}

/// Load the signed-in user's order history.
final class OrdersRequested extends OrdersEvent {
  const OrdersRequested();
}

final class OrderPlaced extends OrdersEvent {
  const OrderPlaced(this.order);
  final FoodOrder order;

  @override
  List<Object?> get props => [order.id];
}
