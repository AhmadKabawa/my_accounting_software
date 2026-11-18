import 'package:accounting_software/app/core/localization/translations/app_key.dart';

/// Texts of the `message` section: the shared message system
/// (`InlineBanner` and `MessageViewWidgets`).
///
/// The `*Label` entries are read by screen readers so the kind of a message is
/// never carried by color or icon alone. The `*Title` entries tell an input
/// problem the user can fix apart from a failure of the system.
enum MessageKeys implements AppKey {
  close(ar: 'إغلاق', en: 'Close'),
  successLabel(ar: 'نجاح', en: 'Success'),
  errorLabel(ar: 'خطأ', en: 'Error'),
  warningLabel(ar: 'تحذير', en: 'Warning'),
  infoLabel(ar: 'معلومة', en: 'Information'),
  validationTitle(ar: 'يرجى مراجعة البيانات', en: 'Please review the data'),
  systemTitle(
    ar: 'تعذّر إكمال العملية',
    en: 'The operation could not be completed',
  );

  const MessageKeys({required this.ar, required this.en});

  @override
  final String ar;
  @override
  final String en;

  @override
  String get key => 'message.$name';
}
