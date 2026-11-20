import 'package:accounting_software/app/core/localization/translations/app_key.dart';

/// User-facing copy owned by the dashboard feature.
enum HomeKeys implements AppKey {
  dashboardTitle(ar: 'لوحة التحكم', en: 'Dashboard'),
  noAvailableCardsTitle(
    ar: 'لا توجد وجهات متاحة حالياً',
    en: 'No destinations are available yet',
  ),
  noAvailableCardsDescription(
    ar: 'ستظهر هنا الشاشات المتاحة لك عند تفعيلها.',
    en: 'Available screens will appear here when they are enabled.',
  );

  const HomeKeys({required this.ar, required this.en});

  @override
  final String ar;

  @override
  final String en;

  @override
  String get key => 'home.$name';
}
