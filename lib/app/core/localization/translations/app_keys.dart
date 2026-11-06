// lib/core/localization/app_keys.dart

import 'app_key.dart';

// lib/core/localization/app_keys.dart

/// ── Namespace موحد ──────────────────────────────
abstract final class AppKeys {
  static const auth = _AuthKeys();
  static const fields = _FieldKeys();
  static const valid = _ValidationKeys();
  static const errors = _ErrorKeys();
  static const server = _ServerErrorKeys();
  static const common = _CommonKeys();
  static const profile = _ProfileKeys();
  static const success = _SuccessKeys();
  static const onBoarding = _OnBordingKeys();
  static const theme = _ThemeKeys();

  static const home = AppKey("mainpage.home");
  static const chat = AppKey("mainpage.chat");
  static const favorite = AppKey("mainpage.favorite");
  static const person = AppKey("mainpage.person");
}

/// ── Theme ───────────────────────────────────────
final class _ThemeKeys {
  const _ThemeKeys();
  final light = const AppKey('theme.light');
  final dark = const AppKey('theme.dark');
  final system = const AppKey('theme.system');
}

final class _OnBordingKeys {
  const _OnBordingKeys();
  final title1 = const AppKey('onboarding.title1');
  final title2 = const AppKey('onboarding.title2');
  final title3 = const AppKey('onboarding.title3');
  final subTitle1 = const AppKey('onboarding.sub_title1');
  final subTitle2 = const AppKey('onboarding.sub_title2');
  final subTitle3 = const AppKey('onboarding.sub_title3');
}

/// ── Auth ────────────────────────────────────────
final class _AuthKeys {
  const _AuthKeys();
  final rememberMe = const AppKey('auth.remember_me');
  final forgotPassword = const AppKey('auth.forgot_password');
  final signIn = const AppKey('auth.sign_in');
  final createAccount = const AppKey('auth.create_account');
  final sendMessage = const AppKey('auth.send_message_to_email');
  final continueGoogle = const AppKey('auth.continue_google');
  final orSignInWith = const AppKey('auth.or_sign_in_with');
  final orSignUpWith = const AppKey('auth.or_sign_up_with');
  final forgetPassword = const AppKey('auth.forget_password');
  final resendEmail = const AppKey('auth.resend_email');
  final registerTitle = const AppKey('auth.register_title');
  final registerSubtitle = const AppKey('auth.register_subtitle');
  final loginTitle = const AppKey('auth.login_title');
  final loginSubtitle = const AppKey('auth.login_subtitle');
  final haveAccount = const AppKey('auth.have_account');
  final noAccount = const AppKey('auth.no_account');
  final sendCode = const AppKey('auth.send_code');
  final forgotPasswordSubtitle = const AppKey('auth.forgot_password_subtitle');
  final resetPasswordTitle = const AppKey('auth.reset_password_title');
  final resetPasswordSubtitle = const AppKey('auth.reset_password_subtitle');
  final resetPassword = const AppKey('auth.reset_password');
  final signOut = const AppKey('auth.sign_out');
}

/// ── Fields ──────────────────────────────────────
final class _FieldKeys {
  const _FieldKeys();
  final email = const AppKey('fields.email');
  final firstName = const AppKey('fields.first_name');
  final lastName = const AppKey('fields.last_name');
  final password = const AppKey('fields.password');
  final confirmPassword = const AppKey('fields.confirm_password');
  final fullName = const AppKey('fields.full_name');
  final phone = const AppKey('fields.phone');
  final bio = const AppKey('fields.bio');
  final currentPassword = const AppKey('fields.current_password');
  final newPassword = const AppKey('fields.new_password');
  final resetCode = const AppKey('fields.reset_code');
}

/// ── Validation ──────────────────────────────────
final class _ValidationKeys {
  const _ValidationKeys();
  final required = const AppKey('validation.required');
  final emailRequired = const AppKey('validation.email_required');
  final emailInvalid = const AppKey('validation.email_invalid');
  final passwordRequired = const AppKey('validation.password_required');
  final passwordMinLength = const AppKey('validation.password_min_length');
  final passwordNeedsUpper = const AppKey('validation.password_needs_upper');
  final passwordNeedsNumber = const AppKey('validation.password_needs_number');
  final passwordNeedsSpecial = const AppKey(
    'validation.password_needs_special',
  );
  final passwordsNotMatch = const AppKey('validation.passwords_not_match');
  final nameRequired = const AppKey('validation.name_required');
  final nameMinLength = const AppKey('validation.name_min_length');
  final phoneInvalid = const AppKey('validation.phone_invalid');
  final fieldMinLength = const AppKey('validation.field_min_length');
  final fieldMaxLength = const AppKey('validation.field_max_length');
}

/// ── Errors ──────────────────────────────────────
final class _ErrorKeys {
  const _ErrorKeys();
  final network = const AppKey('errors.network');
  final timeout = const AppKey('errors.timeout');
  final server = const AppKey('errors.server');
  final unauthorized = const AppKey('errors.unauthorized');
  final forbidden = const AppKey('errors.forbidden');
  final notFound = const AppKey('errors.not_found');
  final validation = const AppKey('errors.validation');
  final cache = const AppKey('errors.cache');
  final permission = const AppKey('errors.permission');
  final unexpected = const AppKey('errors.unexpected');
  final cancelled = const AppKey('errors.cancelled');
  final googleSignIn = const AppKey('errors.google_sign_in');
  final badRequest = const AppKey('errors.bad_request');
  final conflict = const AppKey('errors.conflict');
  final serviceUnavailable = const AppKey('errors.service_unavailable');
  final unknown = const AppKey('errors.unknown');
}

/// ── Server Errors ───────────────────────────────
final class _ServerErrorKeys {
  const _ServerErrorKeys();
  final emailAlreadyExists = const AppKey('server.email_already_exists');
  final emailNotFound = const AppKey('server.email_not_found');
  final invalidCredentials = const AppKey('server.invalid_credentials');
  final accountDisabled = const AppKey('server.account_disabled');
  final tooManyAttempts = const AppKey('server.too_many_attempts');
  final passwordIncorrect = const AppKey('server.password_incorrect');
  final tokenExpired = const AppKey('server.token_expired');
  final tokenInvalid = const AppKey('server.token_invalid');
  final userNotFound = const AppKey('server.user_not_found');
  final phoneAlreadyExists = const AppKey('server.phone_already_exists');
  final unauthenticated = const AppKey('server.unauthenticated');
  final unverifiedEmail = const AppKey('server.unverified_email');
}

/// ── Common ──────────────────────────────────────
final class _CommonKeys {
  const _CommonKeys();
  final retry = const AppKey('common.retry');
  final cancel = const AppKey('common.cancel');
  final confirm = const AppKey('common.confirm');
  final save = const AppKey('common.save');
  final ok = const AppKey('common.ok');
  final loading = const AppKey('common.loading');
  final success = const AppKey('common.success');
  final unknownError = const AppKey('common.unknown_error');
  final optional = const AppKey('common.optional');
  final appName = const AppKey('common.app_name');
  final comingSoon = const AppKey('common.coming_soon');
  final pageNotFound = const AppKey('common.page_not_found');
  final goHome = const AppKey('common.go_home');
}

/// ── Profile ─────────────────────────────────────
final class _ProfileKeys {
  const _ProfileKeys();
  final title = const AppKey('profile.title');
  final edit = const AppKey('profile.edit');
  final saveChanges = const AppKey('profile.save_changes');
  final changePassword = const AppKey('profile.change_password');
  final updateButton = const AppKey('profile.update_button');
  final userNumber = const AppKey('profile.user_number');
}

/// ── Success ─────────────────────────────────────
final class _SuccessKeys {
  const _SuccessKeys();
  final signin = const AppKey('success.sign_in');
  final signup = const AppKey('success.sign_up');
  final signout = const AppKey('success.sign_out');
  final sendMessageToEmail = const AppKey('success.send_message_to_email');
  final profileUpdated = const AppKey('success.profile_updated');
  final passwordChanged = const AppKey('success.password_changed');
}
