import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../data/backend.dart';
import '../../data/mock_data.dart';
import '../../data/models.dart';
import '../../data/repositories.dart';

part 'config_event.dart';
part 'config_state.dart';

/// The app's taxonomy: service tiles, filter chips, saved addresses, ride
/// classes and editorial copy.
///
/// It starts on the bundled values rather than empty, so every screen that
/// reads it renders correctly on the first frame and the fetch only ever
/// refines what is already there. Nothing here is user-specific, so it loads
/// before sign-in.
class ConfigBloc extends Bloc<ConfigEvent, ConfigState> {
  ConfigBloc({ConfigSource? repository})
      : repository = repository ?? Backend.config(),
        super(const ConfigState()) {
    on<ConfigRequested>(_onRequested);
  }

  final ConfigSource repository;

  Future<void> _onRequested(
    ConfigRequested event,
    Emitter<ConfigState> emit,
  ) async {
    if (state.isLoading) return;
    emit(state.copyWith(status: ConfigStatus.loading));
    final remote = await repository.fetch();
    // null means there was nothing to read from, so the bundled taxonomy
    // stands rather than the screens going blank.
    emit(ConfigState(
      config: remote ?? state.config,
      status: ConfigStatus.ready,
      fromRemote: remote != null,
    ));
  }
}
