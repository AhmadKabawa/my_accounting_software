import 'package:accounting_software/app/core/localization/translations/app_key.dart';

enum ShellKeys implements AppKey {
  branch(ar: 'الفرع', en: 'Branch'),
  notificationsUnavailable(
    ar: 'الإشعارات غير متاحة حالياً',
    en: 'Notifications are unavailable',
  ),
  userMenu(ar: 'قائمة المستخدم', en: 'User menu'),
  more(ar: 'المزيد', en: 'More'),
  collapseSidebar(ar: 'طي الشريط الجانبي', en: 'Collapse sidebar'),
  openMenu(ar: 'القائمة الرئيسية', en: 'Main menu'),
  expandSidebar(ar: 'توسيع الشريط الجانبي', en: 'Expand sidebar'),
  expandSection(ar: 'فتح القسم', en: 'Expand section'),
  collapseSection(ar: 'إغلاق القسم', en: 'Collapse section'),
  back(ar: 'رجوع', en: 'Back');

  const ShellKeys({required this.ar, required this.en});

  @override
  final String ar;

  @override
  final String en;

  @override
  String get key => 'shell.$name';
}
