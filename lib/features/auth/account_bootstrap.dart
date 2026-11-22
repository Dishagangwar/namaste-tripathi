import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/bookings/bookings_bloc.dart';
import '../../bloc/favourites/favourites_bloc.dart';
import '../../bloc/orders/orders_bloc.dart';
import '../../bloc/rides/rides_bloc.dart';
import '../../bloc/session/session_bloc.dart';

/// Starts every read that belongs to the account that just signed in.
///
/// Nothing is awaited: the blocs emit as the rows land and the shell rebuilds
/// itself, which beats holding the user on a spinner. It lives here, rather
/// than inline in each screen, because there are now two ways in -- Google
/// and phone OTP -- and a fan-out that differs between them would mean one
/// route silently skipping a bloc.
void loadAccountData(BuildContext context) {
  if (!context.read<SessionBloc>().isSignedIn) return;
  context.read<SessionBloc>().add(const SessionProfileRequested());
  context.read<BookingsBloc>().add(const BookingsRequested());
  context.read<FavouritesBloc>().add(const FavouritesRequested());
  context.read<OrdersBloc>().add(const OrdersRequested());
  context.read<RidesBloc>().add(const RidesRequested());
}
