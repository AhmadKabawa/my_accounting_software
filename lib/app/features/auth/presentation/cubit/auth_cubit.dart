import 'dart:async';

import 'package:accounting_software/app/core/foundation/base_mixin/base/base_cubit/base_side_effects/base_cubit.dart';
import 'package:dartz/dartz.dart' show Either, Unit;
import 'package:accounting_software/app/core/error/error_handling/failure/failure.dart';
import 'package:accounting_software/app/core/error/translators/failure_translator.dart';
import 'package:accounting_software/app/core/foundation/base_mixin/base/base_usecases/use_case.dart';
import 'package:accounting_software/app/core/foundation/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/foundation/localization/translations/app_keys.dart';
import 'package:accounting_software/app/core/presentation/widgets/message_view_widgets.dart';
import 'package:accounting_software/app/core/services/network/cancel/cancellable_mixin.dart';
import 'package:accounting_software/app/features/auth/domain/usecase/change_password_usecase.dart';
import 'package:accounting_software/app/features/auth/domain/usecase/confirm_new_password_usecase.dart';
import 'package:accounting_software/app/features/auth/domain/usecase/get_cached_usecase.dart';
import 'package:accounting_software/app/features/auth/domain/usecase/reset_password_usecase.dart';
import 'package:accounting_software/app/features/auth/domain/usecase/login_usecase.dart';
import 'package:accounting_software/app/features/auth/domain/usecase/logout_usecase.dart';
import 'package:accounting_software/app/features/auth/domain/usecase/register_usecase.dart';
import 'package:accounting_software/app/features/auth/domain/usecase/send_reset_code_usecase.dart';
import 'package:accounting_software/app/features/auth/domain/usecase/signin_with_google_usecase.dart';
import 'package:accounting_software/app/features/auth/domain/usecase/update_profile_usecase.dart';
import 'package:accounting_software/app/features/auth/domain/usecase/verify_reset_code_usecase.dart';
import 'package:accounting_software/app/features/auth/presentation/cubit/effect/auth_effect.dart';
import 'package:accounting_software/app/features/auth/presentation/cubit/states/auth_states.dart';

class AuthCubit extends BaseCubit<AuthState, AuthEffect> with CancellableMixin {
  final LoginUseCase _login;
  final RegisterUseCase _register;
  final LogoutUseCase _logout;
  final SendResetCodeUseCase _sendResetCode;
  final VerifyResetCodeUseCase _verifyResetCode;
  final ConfirmNewPasswordUseCase _confirmNewPassword;
  final ResetPasswordUseCase _resetPassword;
  final ChangePasswordUseCase _changePassword;
  final UpdateProfileUseCase _updateProfile;
  final SignInWithGoogleUseCase _googleSignIn;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  late final StreamSubscription<void> _sessionSub;
  bool _signingOut = false;

  AuthCubit({
    required LoginUseCase login,
    required RegisterUseCase register,
    required LogoutUseCase logout,
    required SendResetCodeUseCase sendResetCode,
    required VerifyResetCodeUseCase verifyResetCode,
    required ConfirmNewPasswordUseCase confirmNewPassword,
    required ResetPasswordUseCase resetPassword,
    required ChangePasswordUseCase changePassword,
    required UpdateProfileUseCase updateProfile,
    required SignInWithGoogleUseCase googleSignIn,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required Stream<void> sessionCleared,
  }) : _login = login,
       _register = register,
       _logout = logout,
       _sendResetCode = sendResetCode,
       _verifyResetCode = verifyResetCode,
       _confirmNewPassword = confirmNewPassword,
       _resetPassword = resetPassword,
       _changePassword = changePassword,
       _updateProfile = updateProfile,
       _googleSignIn = googleSignIn,
       _getCurrentUserUseCase = getCurrentUserUseCase,
       super(const AuthState.initial()) {
    _sessionSub = sessionCleared.listen(_onSessionCleared);
  }

  @override
  Future<void> close() async {
    await _sessionSub.cancel();
    cancelRequests(); //م كلشي فو اتصال بالانترنت

    return super.close();
  }

  // ══════════════════════════════════════════════════
  //  Helpers
  // ══════════════════════════════════════════════════
  void _emitError(Failure failure, {bool replayable = false}) => emitEffect(
    AuthEffect.showMessage(
      messageKey: FailureTranslator.translate(failure),
      type: MessageType.error,
    ),
    replayable: replayable,
  );

  void _emitSuccess(AppKey key) => emitEffect(
    AuthEffect.showMessage(messageKey: key.tran, type: MessageType.success),
  );

  /// The stored session was removed behind our back (e.g. the refresh token
  /// was rejected). A deliberate [signOut] clears it too, so it is ignored.
  void _onSessionCleared(void _) {
    if (_signingOut || state is Unauthenticated || state is AuthInitial) return;
    emit(const AuthState.unauthenticated());
    // Still true on whichever screen shows it (e.g. the login screen the
    // router redirects to), so it may wait briefly for a listener.
    _emitError(UnauthorizedFailure(), replayable: true);
  }

  /// Returns to [previous] unless the session ended while the call was running.
  void _restore(AuthState previous) {
    if (state is AuthLoading) emit(previous);
  }

  // ══════════════════════════════════════════════════
  //  Check Session
  // ══════════════════════════════════════════════════
  Future<void> checkAuthentication() async {
    if (state is Authenticated) return;

    emit(const AuthState.checking());

    final result = await _getCurrentUserUseCase(NoParams());

    result.fold(
      (_) => emit(const AuthState.unauthenticated()),
      (user) => emit(
        user != null
            ? AuthState.authenticated(user: user)
            : const AuthState.unauthenticated(),
      ),
    );
  }

  // ══════════════════════════════════════════════════
  //  Sign In
  // ══════════════════════════════════════════════════
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    emit(const AuthState.loading());

    final result = await _login(LoginParams(email: email, password: password));

    result.fold(
      (failure) {
        emit(const AuthState.unauthenticated());
        _emitError(failure);
      },
      (data) {
        emit(AuthState.authenticated(user: data.user));
        _emitSuccess(AppKeys.success.signin);
      },
    );
  }

  // ══════════════════════════════════════════════════
  //  Sign Up
  // ══════════════════════════════════════════════════
  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    emit(const AuthState.loading());

    final result = await _register(
      RegisterParams(
        email: email,
        password: password,
        name: fullName,
        phone: phone,
      ),
    );

    result.fold(
      (failure) {
        emit(const AuthState.unauthenticated());
        _emitError(failure);
      },
      (data) {
        emit(AuthState.authenticated(user: data.user));
        _emitSuccess(AppKeys.success.signup);
      },
    );
  }

  // ══════════════════════════════════════════════════
  //  Sign Out
  // ══════════════════════════════════════════════════
  Future<void> signOut() async {
    emit(const AuthState.loading());

    _signingOut = true;
    final Either<Failure, Unit> result;
    try {
      result = await _logout(NoParams());
    } finally {
      _signingOut = false;
    }

    result.fold(
      (failure) {
        emit(
          const AuthState.unauthenticated(),
        ); // logout فشل؟ أمّن اطرد المستخدم
        _emitError(failure);
      },
      (_) {
        emit(const AuthState.unauthenticated());
        _emitSuccess(AppKeys.success.signout);
      },
    );
  }

  // ══════════════════════════════════════════════════
  //  Sign In With Google
  // ══════════════════════════════════════════════════
  Future<void> signInWithGoogle() async {
    emit(const AuthState.loading());

    final result = await _googleSignIn(NoParams());

    result.fold(
      (failure) {
        emit(const AuthState.unauthenticated());
        _emitError(failure);
      },
      (data) {
        emit(AuthState.authenticated(user: data.user));
        _emitSuccess(AppKeys.success.signin);
      },
    );
  }

  // ══════════════════════════════════════════════════
  //  Send Reset Code
  // ══════════════════════════════════════════════════
  Future<void> sendResetCode({required String email}) async {
    emit(const AuthState.loading());

    final result = await _sendResetCode(SendResetCodeParams(email: email));

    result.fold(
      (failure) {
        emit(const AuthState.unauthenticated());
        _emitError(failure);
      },
      (_) {
        emit(AuthState.resetCodeSent(email: email));
        _emitSuccess(AppKeys.success.sendMessageToEmail);
      },
    );
  }

  // ══════════════════════════════════════════════════
  //  Verify Reset Code
  // ══════════════════════════════════════════════════
  Future<void> verifyResetCode({
    required String email,
    required String code,
  }) async {
    emit(const AuthState.loading());

    final result = await _verifyResetCode(
      VerifyResetCodeParams(email: email, code: code),
    );

    result.fold(
      (failure) {
        emit(AuthState.resetCodeSent(email: email)); // ← ارجع للخطوة السابقة
        _emitError(failure);
      },
      (_) {
        emit(AuthState.codeVerified(email: email));
        // لا رسالة نجاح هنا — الـ navigation يكفي
      },
    );
  }

  // ══════════════════════════════════════════════════
  //  Confirm New Password
  // ══════════════════════════════════════════════════
  Future<void> confirmNewPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    emit(const AuthState.loading());

    final result = await _confirmNewPassword(
      ConfirmNewPasswordParams(
        email: email,
        code: code,
        newPassword: newPassword,
      ),
    );

    result.fold(
      (failure) {
        emit(AuthState.codeVerified(email: email)); // ← ارجع للخطوة السابقة
        _emitError(failure);
      },
      (_) {
        emit(const AuthState.unauthenticated());
        _emitSuccess(AppKeys.success.passwordChanged); // ← مفتاح مناسب
      },
    );
  }

  // ══════════════════════════════════════════════════
  //  Reset Password (بالـ token)
  // ══════════════════════════════════════════════════
  Future<void> resetPassword({
    required String newPassword,
    required String token,
  }) async {
    emit(const AuthState.loading());

    final result = await _resetPassword(
      ResetPasswordParams(newPassword: newPassword, token: token),
    );

    result.fold(
      (failure) {
        emit(const AuthState.unauthenticated());
        _emitError(failure);
      },
      (_) {
        emit(const AuthState.unauthenticated());
        _emitSuccess(AppKeys.success.passwordChanged);
      },
    );
  }

  // ══════════════════════════════════════════════════
  //  Update Profile
  // ══════════════════════════════════════════════════
  Future<void> updateProfile({
    String? fullName,
    String? avatarUrl,
    String? phone,
  }) async {
    final currentState = state;

    if (currentState is! Authenticated) {
      _emitError(UnauthorizedFailure());
      return;
    }

    emit(const AuthState.loading());

    final result = await _updateProfile(
      UpdateProfileParams(
        fullName: fullName,
        avatarUrl: avatarUrl,
        phone: phone,
      ),
    );

    result.fold(
      (failure) {
        _restore(currentState);
        _emitError(failure);
      },
      (updatedUser) {
        emit(AuthState.authenticated(user: updatedUser));
        _emitSuccess(AppKeys.success.profileUpdated); // ← مفتاح مناسب
      },
    );
  }

  // ══════════════════════════════════════════════════
  //  Change Password
  // ══════════════════════════════════════════════════
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final currentState = state;
    if (currentState is! Authenticated) {
      _emitError(UnauthorizedFailure());
      return;
    }

    emit(const AuthState.loading());

    final result = await _changePassword(
      ChangePasswordParams(
        currentPassword: currentPassword,
        newPassword: newPassword,
      ),
    );

    result.fold(
      (failure) {
        _restore(currentState);
        _emitError(failure);
      },
      (_) {
        _restore(currentState); // ← ابق authenticated
        _emitSuccess(AppKeys.success.passwordChanged); // ← مفتاح مناسب
      },
    );
  }
}
