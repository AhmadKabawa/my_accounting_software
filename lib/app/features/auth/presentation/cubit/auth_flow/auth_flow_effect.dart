import 'package:accounting_software/app/core/localization/translations/app_key.dart';

/// One-shot navigation signals of an auth page.
sealed class AuthFlowEffect {
  const AuthFlowEffect();
}

/// Sign-in was rejected. The login page shows [messageKey] in its own banner
/// (C38), next to the fields, instead of a snackbar that fades away.
final class SignInFailedEffect extends AuthFlowEffect {
  const SignInFailedEffect(this.messageKey);

  final AppKey messageKey;
}

/// The recovery code was sent: open the reset page for [email].
final class ResetCodeSentEffect extends AuthFlowEffect {
  const ResetCodeSentEffect(this.email);

  final String email;
}

/// The password was reset: go back to the login page.
final class PasswordResetEffect extends AuthFlowEffect {
  const PasswordResetEffect();
}
