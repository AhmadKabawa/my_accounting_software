import 'package:accounting_software/app/core/localization/translations/app_key.dart';

/// Texts of the `home` section: one entry = key + Arabic + English.
///
/// Add a text by adding one entry; the key is `<prefix>.<name>` (derived),
/// so it cannot be mistyped or duplicated inside the section.
enum HomeKeys implements AppKey {
  greetingMorning(ar: 'صباح الخير', en: 'Good morning'),
  greetingEvening(ar: 'مساء الخير', en: 'Good evening'),
  greetingWithName(ar: '@greeting، @name', en: '@greeting, @name'),
  sampleDataNotice(
    ar: 'بيانات تجريبية للعرض فقط إلى حين ربط الوحدات المحاسبية',
    en: 'Sample data for preview until the accounting modules are connected',
  ),
  overview(ar: 'نظرة عامة', en: 'Overview'),
  cashBalance(ar: 'رصيد الصندوق', en: 'Cash balance'),
  receivables(ar: 'مستحقات لنا', en: 'Receivables'),
  payables(ar: 'مستحقات علينا', en: 'Payables'),
  monthSales(ar: 'مبيعات الشهر', en: 'Sales this month'),
  quickActions(ar: 'إجراءات سريعة', en: 'Quick actions'),
  newSale(ar: 'فاتورة بيع', en: 'New sale'),
  newPurchase(ar: 'فاتورة شراء', en: 'New purchase'),
  receivePayment(ar: 'سند قبض', en: 'Receive payment'),
  customers(ar: 'العملاء', en: 'Customers'),
  reports(ar: 'التقارير', en: 'Reports'),
  recentActivity(ar: 'آخر الحركات', en: 'Recent activity'),
  noActivity(ar: 'لا توجد حركات بعد', en: 'No activity yet'),
  activitySale(ar: 'بيع', en: 'Sale'),
  activityPurchase(ar: 'شراء', en: 'Purchase'),
  activityPayment(ar: 'دفعة', en: 'Payment'),
  comingSoon(ar: 'هذه الوحدة قيد التطوير', en: 'This module is coming soon'),
  retry(ar: 'إعادة المحاولة', en: 'Retry');

  const HomeKeys({required this.ar, required this.en});

  @override
  final String ar;
  @override
  final String en;

  @override
  String get key => 'home.$name';
}
