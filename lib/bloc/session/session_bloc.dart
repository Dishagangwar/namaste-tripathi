import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../data/backend.dart';
import '../../data/repositories.dart';

part 'session_event.dart';
part 'session_state.dart';

/// Sign-in and the profile that belongs to it.
///
/// Two ways in: Google through the native account picker, and phone OTP where
/// an SMS provider is configured. A build with no Supabase key runs against
/// the demo backend, which grants a session without any console setup -- but
/// it says so rather than reporting a sign-in that did not happen.
class SessionBloc extends Bloc<SessionEvent, SessionState> {
  SessionBloc({AuthSource? auth})
      : auth = auth ?? Backend.auth(),
        super(const SessionState()) {
    on<SessionPhoneChanged>((e, emit) => emit(state.copyWith(phone: e.phone)));
    on<SessionCountryCodeChanged>(
        (e, emit) => emit(state.copyWith(countryCode: e.countryCode)));
    on<SessionErrorCleared>((e, emit) => emit(
        state.copyWith(status: SessionStatus.idle, clearError: true)));
    on<OtpRequested>(_onOtpRequested);
    on<GoogleSignInRequested>(_onGoogleSignInRequested);
    on<OtpSubmitted>(_onOtpSubmitted);
    on<SessionRoleSelected>(_onRoleSelected);
    on<SessionLocationChanged>(_onLocationChanged);
    on<SessionNameChanged>(_onNameChanged);
    on<SessionProfileRequested>(_onProfileRequested);
    on<SessionSignedOut>(_onSignedOut);
  }

  final AuthSource auth;

  /// True when this device holds a real Supabase session.
  bool get isSignedIn => auth.isSignedIn;

  Future<void> _onGoogleSignInRequested(
    GoogleSignInRequested event,
    Emitter<SessionState> emit,
  ) async {
    if (state.isBusy) return;
    emit(state.copyWith(
      status: SessionStatus.signingInWithGoogle,
      clearError: true,
    ));

    final result = await auth.signInWithGoogle();

    emit(switch (result.outcome) {
      SignInOutcome.signedIn => state.copyWith(
          status: SessionStatus.authenticated,
          signedInWithDemoBackend: result.isDemo,
        ),
      // Back to idle with no message: the account sheet was dismissed.
      SignInOutcome.cancelled =>
        state.copyWith(status: SessionStatus.cancelled, clearError: true),
      SignInOutcome.failed => state.copyWith(
          status: SessionStatus.failure,
          errorMessage: result.message ?? 'Could not sign in with Google.',
        ),
    });
  }

  Future<void> _onOtpRequested(
    OtpRequested event,
    Emitter<SessionState> emit,
  ) async {
    emit(state.copyWith(status: SessionStatus.sendingOtp, clearError: true));
    final error = await auth.sendOtp(
      countryCode: state.countryCode,
      phone: state.phone,
    );
    emit(error == null
        ? state.copyWith(status: SessionStatus.otpSent)
        : state.copyWith(status: SessionStatus.failure, errorMessage: error));
  }

  Future<void> _onOtpSubmitted(
    OtpSubmitted event,
    Emitter<SessionState> emit,
  ) async {
    emit(state.copyWith(status: SessionStatus.verifying, clearError: true));
    final error = await auth.verifyOtp(
      countryCode: state.countryCode,
      phone: state.phone,
      token: event.token,
    );
    if (error != null) {
      emit(state.copyWith(
          status: SessionStatus.failure, errorMessage: error));
      return;
    }
    emit(state.copyWith(status: SessionStatus.authenticated));
  }

  Future<void> _onRoleSelected(
    SessionRoleSelected event,
    Emitter<SessionState> emit,
  ) async {
    emit(state.copyWith(role: event.role));
    await auth.saveProfile(role: event.role.name);
  }

  Future<void> _onLocationChanged(
    SessionLocationChanged event,
    Emitter<SessionState> emit,
  ) async {
    emit(state.copyWith(location: event.label, address: event.address));
    await auth.saveProfile(
      locationLabel: event.label,
      address: event.address,
    );
  }

  Future<void> _onNameChanged(
    SessionNameChanged event,
    Emitter<SessionState> emit,
  ) async {
    emit(state.copyWith(name: event.name));
    await auth.saveProfile(fullName: event.name);
  }

  /// Lets a returning user see their own name, role and saved address
  /// instead of the defaults.
  Future<void> _onProfileRequested(
    SessionProfileRequested event,
    Emitter<SessionState> emit,
  ) async {
    final row = await auth.fetchProfile();
    if (row == null) return;

    final remotePhone = row['phone']?.toString() ?? '';
    final fullName = row['full_name']?.toString() ?? '';
    final remoteRole = row['role']?.toString() ?? '';
    final label = row['location_label']?.toString() ?? '';
    final addr = row['address']?.toString() ?? '';

    emit(state.copyWith(
      phone: remotePhone.isNotEmpty ? remotePhone : null,
      name: fullName.isNotEmpty ? fullName : null,
      role: switch (remoteRole) {
        'provider' => JoinRole.provider,
        'user' => JoinRole.user,
        _ => null,
      },
      location: label.isNotEmpty ? label : null,
      address: addr.isNotEmpty ? addr : null,
    ));
  }

  Future<void> _onSignedOut(
    SessionSignedOut event,
    Emitter<SessionState> emit,
  ) async {
    await auth.signOut();
    emit(const SessionState());
  }
}
