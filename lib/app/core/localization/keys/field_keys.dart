import 'package:accounting_software/app/core/localization/translations/app_key.dart';

/// Texts of the `fields` section: one entry = key + Arabic + English.
///
/// Add a text by adding one entry; the key is `<prefix>.<name>` (derived),
/// so it cannot be mistyped or duplicated inside the section.
enum FieldKeys implements AppKey {
  email(ar: 'البريد الإلكتروني', en: 'Email'),
  firstName(ar: 'الاسم الأول', en: 'First name'),
  lastName(ar: 'اسم العائلة', en: 'Last name'),
  password(ar: 'كلمة المرور', en: 'Password'),
  confirmPassword(ar: 'تأكيد كلمة المرور', en: 'Confirm password'),
  fullName(ar: 'الاسم الكامل', en: 'Full name'),
  phone(ar: 'رقم الهاتف', en: 'Phone number'),
  bio(ar: 'السيرة الذاتية', en: 'Bio'),
  currentPassword(ar: 'كلمة المرور الحالية', en: 'Current password'),
  newPassword(ar: 'كلمة المرور الجديدة', en: 'New password'),
  resetCode(ar: 'رمز التحقق', en: 'Verification code');

  const FieldKeys({required this.ar, required this.en});

  @override
  final String ar;
  @override
  final String en;

  @override
  String get key => 'fields.$name';
}
