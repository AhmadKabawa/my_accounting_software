import 'package:accounting_software/app/core/localization/translations/app_key.dart';

/// Texts of the `server` section: one entry = key + Arabic + English.
///
/// Add a text by adding one entry; the key is `<prefix>.<name>` (derived),
/// so it cannot be mistyped or duplicated inside the section.
enum ServerErrorKeys implements AppKey {
  emailAlreadyExists(
    ar: 'البريد الإلكتروني موجود بالفعل',
    en: 'Email already exists',
  ),
  emailNotFound(ar: 'البريد الإلكتروني غير موجود', en: 'Email not found'),
  invalidCredentials(
    ar: 'بريد إلكتروني أو كلمة مرور غير صحيحة',
    en: 'Invalid email or password',
  ),
  accountDisabled(
    ar: 'الحساب معطل، يرجى الاتصال بالدعم',
    en: 'Account disabled, contact support',
  ),
  tooManyAttempts(
    ar: 'محاولات كثيرة جداً، حاول مرة أخرى لاحقاً',
    en: 'Too many attempts, try again later',
  ),
  passwordIncorrect(
    ar: 'كلمة المرور الحالية غير صحيحة',
    en: 'Current password is incorrect',
  ),
  tokenExpired(
    ar: 'رابط إعادة التعيين انتهت صلاحيته',
    en: 'Reset link has expired',
  ),
  tokenInvalid(ar: 'رابط إعادة تعيين غير صالح', en: 'Invalid reset link'),
  userNotFound(ar: 'المستخدم غير موجود', en: 'User not found'),
  phoneAlreadyExists(
    ar: 'رقم الهاتف موجود بالفعل',
    en: 'Phone number already exists',
  ),
  unauthenticated(ar: 'يرجى تسجيل الدخول', en: 'Please login'),
  unverifiedEmail(
    ar: 'يرجى التحقق من بريدك الإلكتروني أولاً',
    en: 'Please verify your email first',
  );

  const ServerErrorKeys({required this.ar, required this.en});

  @override
  final String ar;
  @override
  final String en;

  @override
  String get key => 'server.$name';
}
