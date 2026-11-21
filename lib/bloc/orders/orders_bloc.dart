import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../data/backend.dart';
import '../../data/models.dart';
import '../../data/repositories.dart';

part 'orders_event.dart';
part 'orders_state.dart';

/// Food orders the user has placed.
///
/// Placing one is optimistic: the order is added to the list with its local
/// id so the success screen has something to show immediately, then replaced
/// by the stored row, which carries the id and the reference number the
/// server assigned.
class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  OrdersBloc({OrdersSource? repository})
      : repository = repository ?? Backend.orders(),
        super(const OrdersState()) {
    on<OrdersRequested>(_onRequested);
    on<OrderPlaced>(_onPlaced);
  }

  final OrdersSource repository;

  Future<void> _onRequested(
    OrdersRequested event,
    Emitter<OrdersState> emit,
  ) async {
    if (state.isLoading) return;
    emit(state.copyWith(status: OrdersStatus.loading));
    final remote = await repository.fetch();
    emit(state.copyWith(
      items: remote ?? state.items,
      status: OrdersStatus.ready,
    ));
  }

  Future<void> _onPlaced(OrderPlaced event, Emitter<OrdersState> emit) async {
    emit(state.copyWith(
      items: [event.order, ...state.items],
      status: OrdersStatus.placing,
    ));

    final stored = await repository.place(event.order);

    final items = [...state.items];
    final index = items.indexWhere((o) => o.id == event.order.id);
    // A failed write leaves the optimistic copy in place: the user has seen
    // the order, and losing it from the list would be the greater surprise.
    if (stored != null && index != -1) items[index] = stored;

    emit(state.copyWith(
      items: items,
      status: stored == null ? OrdersStatus.failed : OrdersStatus.ready,
    ));
  }
}
