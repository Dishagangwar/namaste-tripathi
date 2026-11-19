part of 'bookings_bloc.dart';

enum BookingsStatus { initial, loading, ready }

final class BookingsState extends Equatable {
  BookingsState({List<Booking>? items, this.status = BookingsStatus.initial})
      : items = items ?? List.unmodifiable(kBookings);

  /// The sample itinerary, shown until the user's own bookings load.
  final List<Booking> items;
  final BookingsStatus status;

  bool get isLoading => status == BookingsStatus.loading;

  BookingsState copyWith({List<Booking>? items, BookingsStatus? status}) =>
      BookingsState(
        items: items ?? this.items,
        status: status ?? this.status,
      );

  @override
  List<Object?> get props => [items, status];
}
