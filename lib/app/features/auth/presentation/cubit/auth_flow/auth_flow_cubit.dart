import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/base/use_case.dart';
import 'package:accounting_software/app/core/presentation/state_management/base_cubit.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/flash_messages.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/message_view_widgets.dart';
import 'package:accounting_software/app/features/auth/domain/entity/auth_result/auth_result.dart';
import 'package:accounting_software/app/features/auth/domain/usecase/confirm_new_password_usecase.dart';
import 'package:accounting_software/app/features/auth/domain/usecase/login_usecase.dart';
import 'package:accounting_software/app/features/auth/domain/usecase/register_usecase.dart';
import 'package:accounting_software/app/features/auth/domain/usecase/send_reset_code_usecase.dart';
import 'package:accounting_software/app/features/auth/domain/usecase/signin_with_google_usecase.dart';
import 'package:accounting_software/app/features/auth/presentation/cubit/auth_flow/auth_flow_effect.dart';
import 'package:accounting_software/app/features/auth/presentation/cubit/session/session_cubit.dart';
import 'package:accounting_software/app/features/auth/presentation/localization/auth_keys.dart';

enum AuthFlowStatus { idle, loading }

/// One auth page's flow (sign in, sign up, recover password). Created per page
/// (factory), so loading never leaks between pages. The state is only
/// idle/loading; outcomes are messages ([FlashMessages]) and navigation
/// signals ([AuthFlowEffect]).
class AuthFlowCubit extends BaseCubit<AuthFlowStatus, AuthFlowEffect> {
  AuthFlowCubit({
    required LoginUseCase login,
    required RegisterUseCase register,
    required SignInWithGoogleUseCase googleSignIn,
    required SendResetCodeUseCase sendResetCode,
    required ConfirmNewPasswordUseCase confirmNewPassword,
    required SessionCubit session,
    required FlashMessages flash,
  }) : _login = login,
       _register = register,
       _googleSignIn = googleSignIn,
       _sendResetCode = sendResetCode,
       _confirmNewPassword = confirmNewPassword,
       _session = session,
       _flash = flash,
       super(AuthFlowStatus.idle);

  final LoginUseCase _login;
  final RegisterUseCase _register;
  final SignInWithGoogleUseCase _googleSignIn;
  final SendResetCodeUseCase _sendResetCode;
  final ConfirmNewPasswordUseCase _confirmNewPassword;
  final SessionCubit _session;
  final FlashMessages _flash;

  bool get isLoading => state == AuthFlowStatus.loading;

  void _setStatus(AuthFlowStatus status) {
    if (!isClosed) emit(status);
  }

  void _error(Failure failure) =>
      _flash.post(failure.messageKey, MessageType.error);

  void _signedIn(AuthResultEntity data, AuthKeys message) {
    _session.onAuthenticated(data.user);
    _flash.post(message, MessageType.success);
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    if (isLoading) return;
    _setStatus(AuthFlowStatus.loading);
    final result = await _login(LoginParams(email: email, password: password));
    _setStatus(AuthFlowStatus.idle);
    result.fold(_error, (data) => _signedIn(data, AuthKeys.signInSuccess));
  }

  Future<void> signInWithGoogle() async {
    if (isLoading) return;
    _setStatus(AuthFlowStatus.loading);
    final result = await _googleSignIn(NoParams());
    _setStatus(AuthFlowStatus.idle);
    result.fold(_error, (data) => _signedIn(data, AuthKeys.signInSuccess));
  }

  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    if (isLoading) return;
    _setStatus(AuthFlowStatus.loading);
    final result = await _register(
      RegisterParams(
        email: email,
        password: password,
        name: fullName,
        phone: phone,
      ),
    );
    _setStatus(AuthFlowStatus.idle);
    result.fold(_error, (data) => _signedIn(data, AuthKeys.signUpSuccess));
  }

  /// On success the page is told to open the reset page with [email] (it
  /// travels as a route parameter, no shared state).
  Future<void> sendResetCode({required String email}) async {
    if (isLoading) return;
    _setStatus(AuthFlowStatus.loading);
    final result = await _sendResetCode(SendResetCodeParams(email: email));
    _setStatus(AuthFlowStatus.idle);
    result.fold(_error, (_) {
      _flash.post(AuthKeys.emailSent, MessageType.success);
      emitEffect(ResetCodeSentEffect(email));
    });
  }

  /// Supabase checks the code and sets the password in one call.
  Future<void> confirmNewPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    if (isLoading) return;
    _setStatus(AuthFlowStatus.loading);
    final result = await _confirmNewPassword(
      ConfirmNewPasswordParams(
        email: email,
        code: code,
        newPassword: newPassword,
      ),
    );
    _setStatus(AuthFlowStatus.idle);
    result.fold(_error, (_) {
      _flash.post(AuthKeys.passwordResetSuccess, MessageType.success);
      emitEffect(const PasswordResetEffect());
    });
  }
}
