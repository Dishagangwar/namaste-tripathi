part of 'rides_bloc.dart';

enum RidesStatus { initial, loading, booking, ready, failed }

final class RidesState extends Equatable {
  const RidesState({
    this.items = const [],
    this.status = RidesStatus.initial,
  });

  /// Newest first.
  final List<Ride> items;
  final RidesStatus status;

  bool get isLoading => status == RidesStatus.loading;
  bool get isBooking => status == RidesStatus.booking;

  /// The ride the confirm sheet is waiting on.
  Ride? get latest => items.isEmpty ? null : items.first;

  RidesState copyWith({List<Ride>? items, RidesStatus? status}) => RidesState(
        items: items ?? this.items,
        status: status ?? this.status,
      );

  @override
  List<Object?> get props => [items, status];
}
