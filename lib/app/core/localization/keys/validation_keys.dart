import 'package:accounting_software/app/core/localization/translations/app_key.dart';

/// Texts of the `validation` section: one entry = key + Arabic + English.
///
/// Add a text by adding one entry; the key is `<prefix>.<name>` (derived),
/// so it cannot be mistyped or duplicated inside the section.
enum ValidationKeys implements AppKey {
  required(ar: 'هذا الحقل مطلوب', en: 'This field is required'),
  emailRequired(ar: 'البريد الإلكتروني مطلوب', en: 'Email is required'),
  emailInvalid(ar: 'بريد إلكتروني غير صالح', en: 'Invalid email address'),
  passwordRequired(ar: 'كلمة المرور مطلوبة', en: 'Password is required'),
  passwordMinLength(
    ar: 'يجب أن تكون كلمة المرور @length أحرف على الأقل',
    en: 'Password must be at least @length characters',
  ),
  passwordNeedsUpper(
    ar: 'يجب أن تحتوي على حرف كبير واحد على الأقل',
    en: 'Must contain at least one uppercase letter',
  ),
  passwordNeedsNumber(
    ar: 'يجب أن تحتوي على رقم واحد على الأقل',
    en: 'Must contain at least one number',
  ),
  passwordNeedsSpecial(
    ar: 'يجب أن تحتوي على رمز خاص واحد على الأقل',
    en: 'Must contain at least one special character',
  ),
  passwordsNotMatch(
    ar: 'كلمتا المرور غير متطابقتين',
    en: 'Passwords do not match',
  ),
  nameRequired(ar: 'الاسم مطلوب', en: 'Name is required'),
  nameMinLength(
    ar: 'يجب أن يكون الاسم @length أحرف على الأقل',
    en: 'Name must be at least @length characters',
  ),
  phoneInvalid(ar: 'رقم هاتف غير صالح', en: 'Invalid phone number'),
  fieldMinLength(
    ar: 'يجب أن يكون @length أحرف على الأقل',
    en: 'Must be at least @length characters',
  ),
  fieldMaxLength(
    ar: 'يجب ألا يتجاوز @length حرفاً',
    en: 'Must not exceed @length characters',
  );

  const ValidationKeys({required this.ar, required this.en});

  @override
  final String ar;
  @override
  final String en;

  @override
  String get key => 'validation.$name';
}
