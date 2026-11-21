import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../data/backend.dart';
import '../../data/models.dart';
import '../../data/repositories.dart';

part 'rides_event.dart';
part 'rides_state.dart';

/// Bike taxi, e-rickshaw, parcel and cab rides.
///
/// Booking is optimistic for the same reason orders are: the confirm sheet
/// opens on the local ride and picks up the server's reference number when
/// the write lands.
class RidesBloc extends Bloc<RidesEvent, RidesState> {
  RidesBloc({RidesSource? repository})
      : repository = repository ?? Backend.rides(),
        super(const RidesState()) {
    on<RidesRequested>(_onRequested);
    on<RideBooked>(_onBooked);
    on<RideCancelled>(_onCancelled);
  }

  final RidesSource repository;

  Future<void> _onRequested(
    RidesRequested event,
    Emitter<RidesState> emit,
  ) async {
    if (state.isLoading) return;
    emit(state.copyWith(status: RidesStatus.loading));
    final remote = await repository.fetch();
    emit(state.copyWith(
      items: remote ?? state.items,
      status: RidesStatus.ready,
    ));
  }

  Future<void> _onBooked(RideBooked event, Emitter<RidesState> emit) async {
    emit(state.copyWith(
      items: [event.ride, ...state.items],
      status: RidesStatus.booking,
    ));

    final stored = await repository.book(event.ride);

    final items = [...state.items];
    final index = items.indexWhere((r) => r.id == event.ride.id);
    if (stored != null && index != -1) items[index] = stored;

    emit(state.copyWith(
      items: items,
      status: stored == null ? RidesStatus.failed : RidesStatus.ready,
    ));
  }

  /// Cancelled locally only: the demo backend has no cancel route, and a
  /// searching ride that was never assigned has nothing to tell a driver.
  void _onCancelled(RideCancelled event, Emitter<RidesState> emit) {
    final items = [
      for (final ride in state.items)
        if (ride.id == event.rideId)
          ride.copyWith(status: RideStatus.cancelled)
        else
          ride,
    ];
    emit(state.copyWith(items: items, status: RidesStatus.ready));
  }
}
