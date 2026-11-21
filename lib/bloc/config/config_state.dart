part of 'config_bloc.dart';

enum ConfigStatus { initial, loading, ready }

final class ConfigState extends Equatable {
  const ConfigState({
    this.config = kBundledConfig,
    this.status = ConfigStatus.initial,
    this.fromRemote = false,
  });

  final AppConfig config;
  final ConfigStatus status;

  /// True once the backend has answered, as opposed to the bundled defaults.
  final bool fromRemote;

  bool get isLoading => status == ConfigStatus.loading;

  List<ServiceCategory> get categories => config.categories;
  ServiceCategory get wideCategory => config.wideCategory;
  List<SavedPlace> get savedPlaces => config.savedPlaces;
  List<RideOption> get rideOptions => config.rideOptions;
  String get travelerTip => config.travelerTip;

  List<String> filtersFor(String group) => config.filtersFor(group);

  ConfigState copyWith({
    AppConfig? config,
    ConfigStatus? status,
    bool? fromRemote,
  }) =>
      ConfigState(
        config: config ?? this.config,
        status: status ?? this.status,
        fromRemote: fromRemote ?? this.fromRemote,
      );

  // `config` is identity-compared: it is replaced wholesale, never mutated,
  // so a new instance always means new values.
  @override
  List<Object?> get props => [config, status, fromRemote];
}
