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

  static const home = AppKey("mainpage.home");
  static const chat = AppKey("mainpage.chat");
  static const favorite = AppKey("mainpage.favorite");
  static const person = AppKey("mainpage.person");
}

final class _OnBordingKeys {
  const _OnBordingKeys();
  final title1 = const AppKey('onboarding.title1');
  final title2 = const AppKey('onboarding.title1');
  final title3 = const AppKey('onboarding.title1');
  final subTitle1 = const AppKey('onboarding.title1');
  final subTitle2 = const AppKey('onboarding.title1');
  final subTitle3 = const AppKey('onboarding.title1');
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
  final loading = const AppKey('common.loading');
  final success = const AppKey('common.success');
  final unknownError = const AppKey('common.unknown_error');
  final optional = const AppKey('common.optional');
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
  final profileUpdated = const AppKey('success.send_message_to_email');
  final passwordChanged = const AppKey('success.send_message_to_email');
}

/*
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
}

/// ── Auth ────────────────────────────────────────
final class _AuthKeys {
  const _AuthKeys();
  final rememberMe = const AuthKey('auth.remember_me');
  final forgotPassword = const AuthKey('auth.forgot_password');
  final signIn = const AuthKey('auth.sign_in');
  final createAccount = const AuthKey('auth.create_account');
  final sendMessage = const AuthKey('auth.send_message_to_email');
  final continueGoogle = const AuthKey('auth.continue_google');
  final orSignInWith = const AuthKey('auth.or_sign_in_with');
  final orSignUpWith = const AuthKey('auth.or_sign_up_with');
  final forgetPassword = const AuthKey('auth.forget_password');
  final resendEmail = const AuthKey('auth.resend_email');
  final registerTitle = const AuthKey('auth.register_title');
  final registerSubtitle = const AuthKey('auth.register_subtitle');
}

final class AuthKey extends AppKey {
  const AuthKey(super.value);
}

/// ── Fields ──────────────────────────────────────
final class _FieldKeys {
  const _FieldKeys();
  final email = const FieldKey('fields.email');
  final firstName = const FieldKey('fields.first_name');
  final lastName = const FieldKey('fields.last_name');
  final password = const FieldKey('fields.password');
  final confirmPassword = const FieldKey('fields.confirm_password');
  final fullName = const FieldKey('fields.full_name');
  final phone = const FieldKey('fields.phone');
  final bio = const FieldKey('fields.bio');
  final currentPassword = const FieldKey('fields.current_password');
  final newPassword = const FieldKey('fields.new_password');
}

final class FieldKey extends AppKey {
  const FieldKey(super.value);
}

/// ── Validation ──────────────────────────────────
final class _ValidationKeys {
  const _ValidationKeys();
  final required = const ValidationKey('validation.required');
  final emailRequired = const ValidationKey('validation.email_required');
  final emailInvalid = const ValidationKey('validation.email_invalid');
  final passwordRequired = const ValidationKey('validation.password_required');
  final passwordMinLength = const ValidationKey(
    'validation.password_min_length',
  );
  final passwordNeedsUpper = const ValidationKey(
    'validation.password_needs_upper',
  );
  final passwordNeedsNumber = const ValidationKey(
    'validation.password_needs_number',
  );
  final passwordNeedsSpecial = const ValidationKey(
    'validation.password_needs_special',
  );
  final passwordsNotMatch = const ValidationKey(
    'validation.passwords_not_match',
  );
  final nameRequired = const ValidationKey('validation.name_required');
  final nameMinLength = const ValidationKey('validation.name_min_length');
  final phoneInvalid = const ValidationKey('validation.phone_invalid');
  final fieldMinLength = const ValidationKey('validation.field_min_length');
  final fieldMaxLength = const ValidationKey('validation.field_max_length');
}

final class ValidationKey extends AppKey {
  const ValidationKey(super.value);
}

/// ── Errors ──────────────────────────────────────
final class _ErrorKeys {
  const _ErrorKeys();
  final network = const ErrorKey('errors.network');
  final timeout = const ErrorKey('errors.timeout');
  final server = const ErrorKey('errors.server');
  final unauthorized = const ErrorKey('errors.unauthorized');
  final forbidden = const ErrorKey('errors.forbidden');
  final notFound = const ErrorKey('errors.not_found');
  final validation = const ErrorKey('errors.validation');
  final cache = const ErrorKey('errors.cache');
  final permission = const ErrorKey('errors.permission');
  final unexpected = const ErrorKey('errors.unexpected');
  final cancelled = const ErrorKey('errors.cancelled');
  final googleSignIn = const ErrorKey('errors.google_sign_in');
  final badRequest = const ErrorKey('errors.bad_request');
  final conflict = const ErrorKey('errors.conflict');
  final serviceUnavailable = const ErrorKey('errors.service_unavailable');
  final unknown = const ErrorKey('errors.unknown');
}

final class ErrorKey extends AppKey {
  const ErrorKey(super.value);
}

/// ── Server Errors ───────────────────────────────
final class _ServerErrorKeys {
  const _ServerErrorKeys();
  final emailAlreadyExists = const ServerErrorKey(
    'server.email_already_exists',
  );
  final emailNotFound = const ServerErrorKey('server.email_not_found');
  final invalidCredentials = const ServerErrorKey('server.invalid_credentials');
  final accountDisabled = const ServerErrorKey('server.account_disabled');
  final tooManyAttempts = const ServerErrorKey('server.too_many_attempts');
  final passwordIncorrect = const ServerErrorKey('server.password_incorrect');
  final tokenExpired = const ServerErrorKey('server.token_expired');
  final tokenInvalid = const ServerErrorKey('server.token_invalid');
  final userNotFound = const ServerErrorKey('server.user_not_found');
  final phoneAlreadyExists = const ServerErrorKey(
    'server.phone_already_exists',
  );
  final unauthenticated = const ServerErrorKey('server.unauthenticated');
  final unverifiedEmail = const ServerErrorKey('server.unverified_email');
}

final class ServerErrorKey extends AppKey {
  const ServerErrorKey(super.value);
}

/// ── Common ──────────────────────────────────────
final class _CommonKeys {
  const _CommonKeys();
  final retry = const CommonKey('common.retry');
  final cancel = const CommonKey('common.cancel');
  final confirm = const CommonKey('common.confirm');
  final save = const CommonKey('common.save');
  final loading = const CommonKey('common.loading');
  final success = const CommonKey('common.success');
  final unknownError = const CommonKey('common.unknown_error');
  final optional = const CommonKey('common.optional');
}

final class CommonKey extends AppKey {
  const CommonKey(super.value);
}

/// ── Profile ─────────────────────────────────────
final class _ProfileKeys {
  const _ProfileKeys();
  final title = const ProfileKey('profile.title');
  final edit = const ProfileKey('profile.edit');
  final saveChanges = const ProfileKey('profile.save_changes');
  final changePassword = const ProfileKey('profile.change_password');
  final updateButton = const ProfileKey('profile.update_button');
  final userNumber = const ProfileKey('profile.user_number');
}

final class ProfileKey extends AppKey {
  const ProfileKey(super.value);
}

/// ── Success ─────────────────────────────────────
final class _SuccessKeys {
  const _SuccessKeys();
  final signin = const SuccessKey('success.sign_in');
  final signup = const SuccessKey('success.sign_up');
  final signout = const SuccessKey('success.sign_out');
  final sendMessageToEmail = const SuccessKey('success.send_message_to_email');
}

final class SuccessKey extends AppKey {
  const SuccessKey(super.value);
}
*/
