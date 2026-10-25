import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:accounting_software/app/features/auth/domain/entity/user/user_entity.dart';

part 'auth_states.freezed.dart';

@freezed
sealed class AuthState with _$AuthState {
  const AuthState._();

  const factory AuthState.initial() = AuthInitial;
  const factory AuthState.checking() = AuthChecking; // ← أضف
  const factory AuthState.loading() = AuthLoading;
  const factory AuthState.authenticated({required UserEntity user}) =
      Authenticated;
  const factory AuthState.unauthenticated() = Unauthenticated;
  const factory AuthState.passwordResetEmailSent() = PasswordResetEmailSent;
  const factory AuthState.resetCodeSent({required String email}) =
      ResetCodeSent;
  const factory AuthState.codeVerified({required String email}) = CodeVerified;
  // ← احذف error state — الأخطاء تمشي عبر Effect مش State
}
