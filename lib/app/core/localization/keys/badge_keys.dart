import 'package:accounting_software/app/core/localization/translations/app_key.dart';

/// Shared badge labels, available in Arabic and English.
enum BadgeKeys implements AppKey {
  sample(ar: 'حالة المستند', en: 'Document status'),
  draft(ar: 'مسودة', en: 'Draft'),
  posted(ar: 'مُرحّل', en: 'Posted'),
  reversed(ar: 'معكوس', en: 'Reversed'),
  cancelled(ar: 'ملغى', en: 'Cancelled'),
  unpaid(ar: 'غير مدفوع', en: 'Unpaid'),
  partial(ar: 'مدفوع جزئياً', en: 'Partially paid'),
  paid(ar: 'مدفوع', en: 'Paid'),
  unknown(ar: 'حالة غير معروفة', en: 'Unknown status'),
  longLabel(
    ar: 'هذه تسمية طويلة لاختبار التفاف النص داخل الشارة دون تجاوز حدودها',
    en: 'A deliberately long badge label to verify that text wraps within its available width without overflowing',
  );

  const BadgeKeys({required this.ar, required this.en});

  @override
  final String ar;
  @override
  final String en;

  @override
  String get key => 'badge.$name';
}
