import 'package:accounting_software/app/core/localization/translations/app_key.dart';

/// Texts of the `profile` section: one entry = key + Arabic + English.
///
/// Add a text by adding one entry; the key is `<prefix>.<name>` (derived),
/// so it cannot be mistyped or duplicated inside the section.
enum ProfileKeys implements AppKey {
  title(ar: 'الملف الشخصي', en: 'Profile'),
  edit(ar: 'تعديل الملف الشخصي', en: 'Edit profile'),
  saveChanges(ar: 'حفظ التغييرات', en: 'Save changes'),
  changePassword(ar: 'تغيير كلمة المرور', en: 'Change password'),
  updateButton(ar: 'تحديث', en: 'Update'),
  userNumber(ar: 'مستخدم رقم @number', en: 'User #@number'),
  profileUpdated(
    ar: 'تم تحديث الملف الشخصي بنجاح',
    en: 'Profile updated successfully',
  ),
  passwordChanged(
    ar: 'تم تغيير كلمة المرور بنجاح',
    en: 'Password changed successfully',
  );

  const ProfileKeys({required this.ar, required this.en});

  @override
  final String ar;
  @override
  final String en;

  @override
  String get key => 'profile.$name';
}
