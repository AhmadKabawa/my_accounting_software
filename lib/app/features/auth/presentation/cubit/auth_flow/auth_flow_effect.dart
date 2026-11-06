/// One-shot navigation signals of an auth page.
sealed class AuthFlowEffect {
  const AuthFlowEffect();
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
