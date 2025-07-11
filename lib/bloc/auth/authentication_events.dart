part of 'authentication_bloc.dart';

abstract class AuthenticationEvent extends Equatable {
  const AuthenticationEvent();

  @override
  List<Object?> get props => [];
}

/// Initial authentication check
class InitialAuthenticationEvent extends AuthenticationEvent {}

/// Login event
class LoginEvent extends AuthenticationEvent {
  final String email;
  final String password;

  const LoginEvent({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

/// Register event
class RegisterEvent extends AuthenticationEvent {
  final String name;
  final String email;
  final String password;
  final String phone;

  const RegisterEvent({
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
  });

  @override
  List<Object> get props => [name, email, password, phone];
}

/// Logout event
class LogoutEvent extends AuthenticationEvent {}

/// Update profile event
class UpdateProfileEvent extends AuthenticationEvent {
  final String? name;
  final String? phone;

  const UpdateProfileEvent({
    this.name,
    this.phone,
  });

  @override
  List<Object?> get props => [name, phone];
}

/// Change password event
class ChangePasswordEvent extends AuthenticationEvent {
  final String currentPassword;
  final String newPassword;

  const ChangePasswordEvent({
    required this.currentPassword,
    required this.newPassword,
  });

  @override
  List<Object> get props => [currentPassword, newPassword];
}

/// Delete account event
class DeleteAccountEvent extends AuthenticationEvent {}

/// Get profile event
class GetProfileEvent extends AuthenticationEvent {}

/// Refresh token event
class RefreshTokenEvent extends AuthenticationEvent {}

/// Clear error event
class ClearErrorEvent extends AuthenticationEvent {}