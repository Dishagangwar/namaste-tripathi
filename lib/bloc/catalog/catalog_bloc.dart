import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../data/models.dart';
import '../../data/backend.dart';
import '../../data/repositories.dart';

part 'catalog_event.dart';
part 'catalog_state.dart';

/// Owns the catalogue for the whole app.
///
/// The repository never throws and falls back to the bundled lists, so this
/// bloc has no failure state to model -- the worst case is simply that
/// `isLive` stays false.
class CatalogBloc extends Bloc<CatalogEvent, CatalogState> {
  CatalogBloc({CatalogSource? repository})
      : repository = repository ?? Backend.catalog(),
        super(CatalogState.bundled()) {
    on<CatalogRequested>(_onRequested);
    on<CatalogRefreshed>(_onRefreshed);
  }

  final CatalogSource repository;
  bool _loadedOnce = false;

  Future<void> _onRequested(
    CatalogRequested event,
    Emitter<CatalogState> emit,
  ) async {
    if (_loadedOnce) return;
    await _load(emit);
  }

  Future<void> _onRefreshed(
    CatalogRefreshed event,
    Emitter<CatalogState> emit,
  ) =>
      _load(emit);

  Future<void> _load(Emitter<CatalogState> emit) async {
    emit(state.copyWith(status: CatalogStatus.loading));
    final data = await repository.fetch();
    _loadedOnce = true;
    emit(CatalogState._fromData(data, CatalogStatus.ready));
  }
}
