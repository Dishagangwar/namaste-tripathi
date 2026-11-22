part of 'session_bloc.dart';

enum JoinRole { user, provider }

/// Where the sign-in flow has got to.
enum SessionStatus {
  /// Nothing in flight.
  idle,

  /// Asking Supabase to send a code.
  sendingOtp,

  /// The code was sent; the OTP screen can open.
  otpSent,

  /// Checking the code the user typed.
  verifying,

  /// Waiting on Google's account sheet and the token exchange.
  signingInWithGoogle,

  /// A real session exists on this device.
  authenticated,

  /// The user backed out of the provider's account sheet. Not a failure, and
  /// carries no message: nothing should be shown for changing your mind.
  cancelled,

  /// The last attempt failed; [SessionState.errorMessage] says why.
  failure,
}

final class SessionState extends Equatable {
  const SessionState({
    this.phone = '',
    this.countryCode = '+91',
    this.role = JoinRole.user,
    this.location = 'Home',
    this.address = 'Diya Green City, Rajnagar Extension',
    this.name = 'Darsh',
    this.status = SessionStatus.idle,
    this.errorMessage,
  });

  final String phone;
  final String countryCode;
  final JoinRole role;
  final String location;
  final String address;
  final String name;
  final SessionStatus status;

  /// The server's own message, surfaced verbatim so a provider misconfigured
  /// in the dashboard names itself rather than hiding behind a generic line.
  final String? errorMessage;

  bool get isSendingOtp => status == SessionStatus.sendingOtp;
  bool get isVerifying => status == SessionStatus.verifying;
  bool get isSigningInWithGoogle =>
      status == SessionStatus.signingInWithGoogle;
  bool get isBusy => isSendingOtp || isVerifying || isSigningInWithGoogle;

  SessionState copyWith({
    String? phone,
    String? countryCode,
    JoinRole? role,
    String? location,
    String? address,
    String? name,
    SessionStatus? status,
    String? errorMessage,
    bool clearError = false,
  }) =>
      SessionState(
        phone: phone ?? this.phone,
        countryCode: countryCode ?? this.countryCode,
        role: role ?? this.role,
        location: location ?? this.location,
        address: address ?? this.address,
        name: name ?? this.name,
        status: status ?? this.status,
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      );

  @override
  List<Object?> get props => [
        phone,
        countryCode,
        role,
        location,
        address,
        name,
        status,
        errorMessage,
      ];
}
