import 'package:accounting_software/app/core/localization/translations/app_key.dart';

/// Texts of the `errors` section: one entry = key + Arabic + English.
///
/// Add a text by adding one entry; the key is `<prefix>.<name>` (derived),
/// so it cannot be mistyped or duplicated inside the section.
enum ErrorKeys implements AppKey {
  network(ar: 'لا يوجد اتصال بالإنترنت', en: 'No internet connection'),
  timeout(
    ar: 'انتهت مهلة الطلب، يرجى المحاولة مرة أخرى',
    en: 'Request timeout, please try again',
  ),
  server(
    ar: 'خطأ في الخادم، يرجى المحاولة مرة أخرى',
    en: 'Server error, please try again',
  ),
  unauthorized(
    ar: 'انتهت جلستك، يرجى تسجيل الدخول مرة أخرى',
    en: 'Your session has expired, please login again',
  ),
  forbidden(
    ar: 'ليس لديك صلاحية لهذا الإجراء',
    en: 'You don\'t have permission for this action',
  ),
  notFound(ar: 'المورد المطلوب غير موجود', en: 'Requested resource not found'),
  validation(ar: 'يرجى التحقق من المدخلات', en: 'Please check your input'),
  cache(ar: 'خطأ في ذاكرة التخزين المؤقت', en: 'Cache error'),
  permission(
    ar: 'ليس لديك صلاحية لهذا الإجراء',
    en: 'You don\'t have permission for this action',
  ),
  unexpected(ar: 'حدث خطأ غير متوقع', en: 'An unexpected error occurred'),
  cancelled(ar: 'تم إلغاء العملية', en: 'Operation cancelled'),
  googleSignIn(
    ar: 'فشل تسجيل الدخول بواسطة Google',
    en: 'Google sign in failed',
  ),
  badRequest(ar: 'طلب غير صالح', en: 'Bad request'),
  conflict(ar: 'تضارب في البيانات', en: 'Data conflict'),
  serviceUnavailable(ar: 'الخدمة غير متاحة', en: 'Service unavailable'),
  unknown(ar: 'خطأ غير معروف', en: 'Unknown error');

  const ErrorKeys({required this.ar, required this.en});

  @override
  final String ar;
  @override
  final String en;

  @override
  String get key => 'errors.$name';
}
