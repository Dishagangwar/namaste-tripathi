part of 'session_bloc.dart';

sealed class SessionEvent extends Equatable {
  const SessionEvent();

  @override
  List<Object?> get props => const [];
}

final class SessionPhoneChanged extends SessionEvent {
  const SessionPhoneChanged(this.phone);
  final String phone;

  @override
  List<Object?> get props => [phone];
}

final class SessionCountryCodeChanged extends SessionEvent {
  const SessionCountryCodeChanged(this.countryCode);
  final String countryCode;

  @override
  List<Object?> get props => [countryCode];
}

/// Ask Supabase to text a code to the number already in state.
final class OtpRequested extends SessionEvent {
  const OtpRequested();
}

final class OtpSubmitted extends SessionEvent {
  const OtpSubmitted(this.token);
  final String token;

  @override
  List<Object?> get props => [token];
}

/// Clears a failure so the screen can leave its error state.
final class SessionErrorCleared extends SessionEvent {
  const SessionErrorCleared();
}

final class SessionRoleSelected extends SessionEvent {
  const SessionRoleSelected(this.role);
  final JoinRole role;

  @override
  List<Object?> get props => [role];
}

final class SessionLocationChanged extends SessionEvent {
  const SessionLocationChanged(this.label, this.address);
  final String label;
  final String address;

  @override
  List<Object?> get props => [label, address];
}

final class SessionNameChanged extends SessionEvent {
  const SessionNameChanged(this.name);
  final String name;

  @override
  List<Object?> get props => [name];
}

/// Pull the profile row written at sign-up.
final class SessionProfileRequested extends SessionEvent {
  const SessionProfileRequested();
}

final class SessionSignedOut extends SessionEvent {
  const SessionSignedOut();
}
