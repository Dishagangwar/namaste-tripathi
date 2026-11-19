part of 'favourites_bloc.dart';

sealed class FavouritesEvent extends Equatable {
  const FavouritesEvent();

  @override
  List<Object?> get props => const [];
}

/// Pull the signed-in user's saved items; a no-op when signed out.
final class FavouritesRequested extends FavouritesEvent {
  const FavouritesRequested();
}

final class FavouritePropertyToggled extends FavouritesEvent {
  const FavouritePropertyToggled(this.propertyId);
  final String propertyId;

  @override
  List<Object?> get props => [propertyId];
}

final class FavouriteRestaurantToggled extends FavouritesEvent {
  const FavouriteRestaurantToggled(this.restaurantId);
  final String restaurantId;

  @override
  List<Object?> get props => [restaurantId];
}
