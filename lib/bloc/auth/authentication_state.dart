part of 'authentication_bloc.dart';

enum AuthenticationStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  failure,
}

class AuthenticationState extends Equatable {
  final AuthenticationStatus status;
  final User? user;
  final String? token;
  final String? errorMessage;
  final String? successMessage;

  const AuthenticationState({
    this.status = AuthenticationStatus.initial,
    this.user,
    this.token,
    this.errorMessage,
    this.successMessage,
  });

  @override
  List<Object?> get props => [
        status,
        user,
        token,
        errorMessage,
        successMessage,
      ];

  // Convenience getters
  bool get isInitial => status == AuthenticationStatus.initial;
  bool get isLoading => status == AuthenticationStatus.loading;
  bool get isAuthenticated => status == AuthenticationStatus.authenticated;
  bool get isUnauthenticated => status == AuthenticationStatus.unauthenticated;
  bool get isFailure => status == AuthenticationStatus.failure;
  bool get hasError => errorMessage != null;
  bool get hasSuccess => successMessage != null;

  AuthenticationState copyWith({
    AuthenticationStatus? status,
    User? user,
    String? token,
    String? errorMessage,
    String? successMessage,
  }) {
    return AuthenticationState(
      status: status ?? this.status,
      user: user ?? this.user,
      token: token ?? this.token,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  @override
  String toString() {
    return '''AuthenticationState {
      status: $status,
      user: ${user?.name ?? 'null'},
      hasToken: ${token != null},
      errorMessage: $errorMessage,
      successMessage: $successMessage,
    }''';
  }
}