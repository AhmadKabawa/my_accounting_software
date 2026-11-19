import 'package:accounting_software/app/core/localization/translations/app_key.dart';

enum ShellKeys implements AppKey {
  branch(ar: 'الفرع', en: 'Branch'),
  notificationsUnavailable(ar: 'الإشعارات غير متاحة حالياً', en: 'Notifications are unavailable'),
  userMenu(ar: 'قائمة المستخدم', en: 'User menu');

  const ShellKeys({required this.ar, required this.en});
  @override
  final String ar;
  @override
  final String en;
  @override
  String get key => 'shell.$name';
}
