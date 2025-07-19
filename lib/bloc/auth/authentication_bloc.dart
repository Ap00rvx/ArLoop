import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../services/authentication_service.dart';
import '../../models/user.dart';

part 'authentication_events.dart';
part 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final AuthenticationService _authService;

  AuthenticationBloc({AuthenticationService? authService})
    : _authService = authService ?? AuthenticationService(),
      super(const AuthenticationState()) {
    on<InitialAuthenticationEvent>(_onInitialAuthentication);
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<LogoutEvent>(_onLogout);
    on<UpdateProfileEvent>(_onUpdateProfile);
    on<ChangePasswordEvent>(_onChangePassword);
    on<DeleteAccountEvent>(_onDeleteAccount);
    on<GetProfileEvent>(_onGetProfile);
    on<RefreshTokenEvent>(_onRefreshToken);
    on<ClearErrorEvent>(_onClearError);
  }

  /// Initialize authentication state
  Future<void> _onInitialAuthentication(
    InitialAuthenticationEvent event,
    Emitter<AuthenticationState> emit,
  ) async {
    emit(state.copyWith(status: AuthenticationStatus.loading));

    try {
      await _authService.initialize();

      if (_authService.isLoggedIn && _authService.currentUser != null) {
        // Verify token is still valid
        final isValid = await _authService.isTokenValid();

        if (isValid) {
          emit(
            state.copyWith(
              status: AuthenticationStatus.authenticated,
              user: _authService.currentUser,
              token: _authService.authToken,
            ),
          );
        } else {
          // Token invalid, logout
          await _authService.logout();
          emit(state.copyWith(status: AuthenticationStatus.unauthenticated));
        }
      } else {
        emit(state.copyWith(status: AuthenticationStatus.unauthenticated));
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthenticationStatus.failure,
          errorMessage: 'Failed to initialize authentication: ${e.toString()}',
        ),
      );
    }
  }

  /// Handle login
  Future<void> _onLogin(
    LoginEvent event,
    Emitter<AuthenticationState> emit,
  ) async {
    emit(state.copyWith(status: AuthenticationStatus.loading));

    try {
      final result = await _authService.login(
        email: event.email,
        password: event.password,
      );

      if (result.isSuccess) {
        emit(
          state.copyWith(
            status: AuthenticationStatus.authenticated,
            user: result.user,
            token: _authService.authToken,
            successMessage: result.message,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: AuthenticationStatus.failure,
            errorMessage: result.message,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthenticationStatus.failure,
          errorMessage: 'Login failed: ${e.toString()}',
        ),
      );
    }
  }

  /// Handle registration
  Future<void> _onRegister(
    RegisterEvent event,
    Emitter<AuthenticationState> emit,
  ) async {
    emit(state.copyWith(status: AuthenticationStatus.loading));

    try {
      final result = await _authService.register(
        name: event.name,
        email: event.email,
        password: event.password,
        phone: event.phone,
      );

      if (result.isSuccess) {
        emit(
          state.copyWith(
            status: AuthenticationStatus.authenticated,
            user: result.user,
            token: _authService.authToken,
            successMessage: result.message,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: AuthenticationStatus.failure,
            errorMessage: result.message,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthenticationStatus.failure,
          errorMessage: 'Registration failed: ${e.toString()}',
        ),
      );
    }
  }

  /// Handle logout
  Future<void> _onLogout(
    LogoutEvent event,
    Emitter<AuthenticationState> emit,
  ) async {
    emit(state.copyWith(status: AuthenticationStatus.loading));

    try {
      await _authService.logout();
      emit(
        state.copyWith(
          status: AuthenticationStatus.unauthenticated,
          user: null,
          token: null,
          successMessage: 'Logged out successfully',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthenticationStatus.failure,
          errorMessage: 'Logout failed: ${e.toString()}',
        ),
      );
    }
  }

  /// Handle profile update
  Future<void> _onUpdateProfile(
    UpdateProfileEvent event,
    Emitter<AuthenticationState> emit,
  ) async {
    emit(state.copyWith(status: AuthenticationStatus.loading));

    try {
      final result = await _authService.updateProfile(
        name: event.name,
        phone: event.phone,
      );

      if (result.isSuccess) {
        emit(
          state.copyWith(
            status: AuthenticationStatus.authenticated,
            user: result.user,
            successMessage: result.message,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: AuthenticationStatus.failure,
            errorMessage: result.message,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthenticationStatus.failure,
          errorMessage: 'Profile update failed: ${e.toString()}',
        ),
      );
    }
  }

  /// Handle password change
  Future<void> _onChangePassword(
    ChangePasswordEvent event,
    Emitter<AuthenticationState> emit,
  ) async {
    emit(state.copyWith(status: AuthenticationStatus.loading));

    try {
      final result = await _authService.changePassword(
        currentPassword: event.currentPassword,
        newPassword: event.newPassword,
      );

      if (result.isSuccess) {
        emit(
          state.copyWith(
            status: AuthenticationStatus.authenticated,
            successMessage: result.message,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: AuthenticationStatus.failure,
            errorMessage: result.message,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthenticationStatus.failure,
          errorMessage: 'Password change failed: ${e.toString()}',
        ),
      );
    }
  }

  /// Handle account deletion
  Future<void> _onDeleteAccount(
    DeleteAccountEvent event,
    Emitter<AuthenticationState> emit,
  ) async {
    emit(state.copyWith(status: AuthenticationStatus.loading));

    try {
      final result = await _authService.deleteAccount();

      if (result.isSuccess) {
        emit(
          state.copyWith(
            status: AuthenticationStatus.unauthenticated,
            user: null,
            token: null,
            successMessage: result.message,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: AuthenticationStatus.failure,
            errorMessage: result.message,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthenticationStatus.failure,
          errorMessage: 'Account deletion failed: ${e.toString()}',
        ),
      );
    }
  }

  /// Handle get profile
  Future<void> _onGetProfile(
    GetProfileEvent event,
    Emitter<AuthenticationState> emit,
  ) async {
    emit(state.copyWith(status: AuthenticationStatus.loading));

    try {
      final result = await _authService.getUserProfile();
      print('Get Profile Result: ${result.message}');

      if (result.isSuccess) {
        emit(
          state.copyWith(
            status: AuthenticationStatus.authenticated,
            user: result.user,
            successMessage: result.message,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: AuthenticationStatus.failure,
            errorMessage: result.message,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthenticationStatus.failure,
          errorMessage: 'Failed to get profile: ${e.toString()}',
        ),
      );
    }
  }

  /// Handle token refresh
  Future<void> _onRefreshToken(
    RefreshTokenEvent event,
    Emitter<AuthenticationState> emit,
  ) async {
    try {
      final isValid = await _authService.isTokenValid();

      if (!isValid) {
        await _authService.logout();
        emit(
          state.copyWith(
            status: AuthenticationStatus.unauthenticated,
            user: null,
            token: null,
            errorMessage: 'Session expired. Please login again.',
          ),
        );
      } else {
        await _authService.refreshUserData();
        emit(
          state.copyWith(
            status: AuthenticationStatus.authenticated,
            user: _authService.currentUser,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthenticationStatus.failure,
          errorMessage: 'Token refresh failed: ${e.toString()}',
        ),
      );
    }
  }

  /// Clear error message
  Future<void> _onClearError(
    ClearErrorEvent event,
    Emitter<AuthenticationState> emit,
  ) async {
    emit(state.copyWith(errorMessage: null, successMessage: null));
  }
}
