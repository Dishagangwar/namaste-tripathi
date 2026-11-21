part of 'orders_bloc.dart';

enum OrdersStatus { initial, loading, placing, ready, failed }

final class OrdersState extends Equatable {
  const OrdersState({
    this.items = const [],
    this.status = OrdersStatus.initial,
  });

  /// Newest first.
  final List<FoodOrder> items;
  final OrdersStatus status;

  bool get isLoading => status == OrdersStatus.loading;
  bool get isPlacing => status == OrdersStatus.placing;

  /// The most recent order, which is the one the success screen shows.
  FoodOrder? get latest => items.isEmpty ? null : items.first;

  OrdersState copyWith({List<FoodOrder>? items, OrdersStatus? status}) =>
      OrdersState(
        items: items ?? this.items,
        status: status ?? this.status,
      );

  @override
  List<Object?> get props => [items, status];
}
