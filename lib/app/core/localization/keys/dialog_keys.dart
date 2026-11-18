import 'package:accounting_software/app/core/localization/translations/app_key.dart';

/// Texts of the `dialog` section: the shared `ConfirmDialog`.
///
/// The confirm and cancel buttons reuse `CommonKeys.confirm` / `cancel`.
enum DialogKeys implements AppKey {
  typeToConfirm(ar: 'اكتب "@name" للتأكيد', en: 'Type "@name" to confirm'),
  typedNameLabel(ar: 'اسم الهدف', en: 'Target name'),
  impactTitle(ar: 'ما الذي سيتغيّر', en: 'What will change'),
  criticalLabel(ar: 'إجراء حرج', en: 'Critical action'),
  warningLabel(ar: 'تنبيه', en: 'Warning');

  const DialogKeys({required this.ar, required this.en});

  @override
  final String ar;
  @override
  final String en;

  @override
  String get key => 'dialog.$name';
}
