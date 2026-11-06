import 'package:accounting_software/app/core/localization/translations/app_key.dart';

/// Texts of the `common` section: one entry = key + Arabic + English.
///
/// Add a text by adding one entry; the key is `<prefix>.<name>` (derived),
/// so it cannot be mistyped or duplicated inside the section.
enum CommonKeys implements AppKey {
  retry(ar: 'إعادة المحاولة', en: 'Retry'),
  cancel(ar: 'إلغاء', en: 'Cancel'),
  confirm(ar: 'تأكيد', en: 'Confirm'),
  save(ar: 'حفظ', en: 'Save'),
  ok(ar: 'موافق', en: 'OK'),
  loading(ar: 'جاري التحميل...', en: 'Loading...'),
  success(ar: 'تم بنجاح', en: 'Success'),
  unknownError(ar: 'حدث خطأ غير متوقع', en: 'An unexpected error occurred'),
  optional(ar: 'اختياري', en: 'Optional'),
  appName(ar: 'البرنامج المحاسبي', en: 'Accounting Software'),
  comingSoon(ar: 'قريباً', en: 'Coming soon'),
  pageNotFound(ar: 'الصفحة غير موجودة', en: 'Page not found'),
  goHome(ar: 'العودة للرئيسية', en: 'Go home');

  const CommonKeys({required this.ar, required this.en});

  @override
  final String ar;
  @override
  final String en;

  @override
  String get key => 'common.$name';
}
