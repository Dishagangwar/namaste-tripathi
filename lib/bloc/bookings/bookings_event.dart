part of 'bookings_bloc.dart';

sealed class BookingsEvent extends Equatable {
  const BookingsEvent();

  @override
  List<Object?> get props => const [];
}

/// Load the signed-in user's bookings, replacing the sample itinerary.
final class BookingsRequested extends BookingsEvent {
  const BookingsRequested();
}

final class BookingAdded extends BookingsEvent {
  const BookingAdded(this.booking);
  final Booking booking;

  @override
  List<Object?> get props => [booking.id];
}
