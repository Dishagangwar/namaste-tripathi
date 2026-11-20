import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../data/mock_data.dart';
import '../../data/models.dart';
import '../../data/backend.dart';
import '../../data/repositories.dart';

part 'bookings_event.dart';
part 'bookings_state.dart';

/// Hotel stays, visits and orders for the signed-in user.
class BookingsBloc extends Bloc<BookingsEvent, BookingsState> {
  BookingsBloc({BookingsSource? repository})
      : repository = repository ?? Backend.bookings(),
        super(BookingsState()) {
    on<BookingsRequested>(_onRequested);
    on<BookingAdded>(_onAdded);
  }

  final BookingsSource repository;

  Future<void> _onRequested(
    BookingsRequested event,
    Emitter<BookingsState> emit,
  ) async {
    if (state.isLoading) return;
    emit(state.copyWith(status: BookingsStatus.loading));
    final remote = await repository.fetch();
    // null means there was nothing to read from, so keep what is on screen.
    emit(state.copyWith(
      items: remote ?? state.items,
      status: BookingsStatus.ready,
    ));
  }

  Future<void> _onAdded(BookingAdded event, Emitter<BookingsState> emit) async {
    // Show it straight away, then swap in the stored row so it carries the
    // database id rather than the locally generated one.
    emit(state.copyWith(items: [event.booking, ...state.items]));

    final stored = await repository.add(event.booking);
    if (stored == null) return;
    final items = [...state.items];
    final index = items.indexWhere((b) => b.id == event.booking.id);
    if (index == -1) return;
    items[index] = stored;
    emit(state.copyWith(items: items));
  }
}
