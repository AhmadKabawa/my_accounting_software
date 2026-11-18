import 'package:accounting_software/app/core/localization/translations/app_key.dart';

enum AccessKeys implements AppKey {
  loading(ar: 'جارٍ تحميل صلاحيات الحساب...', en: 'Loading account access...'),
  loadFailed(
    ar: 'تعذر تحميل صلاحيات الحساب. لا يمكن فتح وظائف النظام قبل نجاح التحميل.',
    en: 'Account access could not be loaded. System features remain locked until it succeeds.',
  ),
  noAvailableBranches(
    ar: 'لا توجد فروع متاحة لهذا الحساب.',
    en: 'No branches are available for this account.',
  );

  const AccessKeys({required this.ar, required this.en});
  @override
  final String ar;
  @override
  final String en;
  @override
  String get key => 'access.$name';
}
