import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:social_app/src/modules/auth/domain/entities/user_entity.dart';

part 'auth_state.freezed.dart';
@freezed
class AuthState with _$AuthState {
  const factory AuthState.unauthenticated({
    @Default('') String emailError,
    @Default('') String passwordError,
    String? errorMessage,
    @Default(false) bool isEmailValid,
    @Default(false) bool isPasswordValid,
  }) = _Unauthenticated;
  const factory AuthState.loading() = _Loading;
  const factory AuthState.authenticated(String userId) = _Authenticated;
  const factory AuthState.failure(String message) = _Failure;
  const factory AuthState.googleLoading() = _GoogleLoading; 
  const factory AuthState.pendingVerification({required String email}) = _PendingVerification;
  const factory AuthState.passwordRecovery() = _PasswordRecovery;
  const factory AuthState.userInfoLoaded(UserEntity user) = _UserInfoLoaded;
  const factory AuthState.updatePasswordSuccess() = _UpdatePasswordSuccess;
  const factory AuthState.passwordResetSent({required String email}) = _PasswordResetSent;
}