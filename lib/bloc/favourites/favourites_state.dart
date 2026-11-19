part of 'favourites_bloc.dart';

final class FavouritesState extends Equatable {
  const FavouritesState({
    this.propertyIds = const {'pr6', 'pr4', 'pr2'},
    this.restaurantIds = const {'r1'},
  });

  /// Pre-seeded so the app has something to show before sign-in; replaced
  /// wholesale by the user's own rows once Supabase answers.
  final Set<String> propertyIds;
  final Set<String> restaurantIds;

  bool isPropertyFavourite(String id) => propertyIds.contains(id);
  bool isRestaurantSaved(String id) => restaurantIds.contains(id);

  FavouritesState copyWith({
    Set<String>? propertyIds,
    Set<String>? restaurantIds,
  }) =>
      FavouritesState(
        propertyIds: propertyIds ?? this.propertyIds,
        restaurantIds: restaurantIds ?? this.restaurantIds,
      );

  @override
  List<Object?> get props => [propertyIds, restaurantIds];
}
