import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../data/remote/favourites_repository.dart';

part 'favourites_event.dart';
part 'favourites_state.dart';

/// Saved properties and restaurants.
///
/// Toggles are optimistic: the new state is emitted immediately and the
/// write follows. The tap has already been reflected on screen, so a failed
/// write is logged by the repository rather than bounced back at the user.
class FavouritesBloc extends Bloc<FavouritesEvent, FavouritesState> {
  FavouritesBloc({this.repository = const FavouritesRepository()})
      : super(const FavouritesState()) {
    on<FavouritesRequested>(_onRequested);
    on<FavouritePropertyToggled>(_onPropertyToggled);
    on<FavouriteRestaurantToggled>(_onRestaurantToggled);
  }

  final FavouritesRepository repository;

  Future<void> _onRequested(
    FavouritesRequested event,
    Emitter<FavouritesState> emit,
  ) async {
    final grouped = await repository.fetch();
    if (grouped == null) return;
    emit(FavouritesState(
      propertyIds: grouped[FavouritesRepository.propertyType] ?? const {},
      restaurantIds: grouped[FavouritesRepository.restaurantType] ?? const {},
    ));
  }

  Future<void> _onPropertyToggled(
    FavouritePropertyToggled event,
    Emitter<FavouritesState> emit,
  ) async {
    final next = {...state.propertyIds};
    final added = next.add(event.propertyId);
    if (!added) next.remove(event.propertyId);
    emit(state.copyWith(propertyIds: next));
    await _sync(FavouritesRepository.propertyType, event.propertyId, added);
  }

  Future<void> _onRestaurantToggled(
    FavouriteRestaurantToggled event,
    Emitter<FavouritesState> emit,
  ) async {
    final next = {...state.restaurantIds};
    final added = next.add(event.restaurantId);
    if (!added) next.remove(event.restaurantId);
    emit(state.copyWith(restaurantIds: next));
    await _sync(FavouritesRepository.restaurantType, event.restaurantId, added);
  }

  Future<void> _sync(String type, String id, bool added) =>
      added ? repository.add(type, id) : repository.remove(type, id);
}
