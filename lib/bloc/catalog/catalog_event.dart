part of 'catalog_bloc.dart';

sealed class CatalogEvent extends Equatable {
  const CatalogEvent();

  @override
  List<Object?> get props => const [];
}

/// Load the catalogue once. Ignored if it has already loaded.
final class CatalogRequested extends CatalogEvent {
  const CatalogRequested();
}

/// Re-fetch even if the catalogue is already loaded, for pull-to-refresh.
final class CatalogRefreshed extends CatalogEvent {
  const CatalogRefreshed();
}
