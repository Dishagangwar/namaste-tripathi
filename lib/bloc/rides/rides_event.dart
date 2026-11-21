part of 'rides_bloc.dart';

sealed class RidesEvent extends Equatable {
  const RidesEvent();

  @override
  List<Object?> get props => const [];
}

/// Load the signed-in user's ride history.
final class RidesRequested extends RidesEvent {
  const RidesRequested();
}

final class RideBooked extends RidesEvent {
  const RideBooked(this.ride);
  final Ride ride;

  @override
  List<Object?> get props => [ride.id];
}

final class RideCancelled extends RidesEvent {
  const RideCancelled(this.rideId);
  final String rideId;

  @override
  List<Object?> get props => [rideId];
}
