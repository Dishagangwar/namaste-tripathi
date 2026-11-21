part of 'config_bloc.dart';

sealed class ConfigEvent extends Equatable {
  const ConfigEvent();

  @override
  List<Object?> get props => const [];
}

/// Load the taxonomy. Dispatched at startup, before sign-in.
final class ConfigRequested extends ConfigEvent {
  const ConfigRequested();
}
