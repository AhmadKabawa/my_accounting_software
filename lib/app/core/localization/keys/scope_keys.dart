import 'package:accounting_software/app/core/localization/translations/app_key.dart';

/// Texts of the `scope` section: the shared `ScopeSelector`
/// (branch / warehouse / currency picker).
enum ScopeKeys implements AppKey {
  viewOnly(ar: 'عرض فقط', en: 'View only'),
  current(ar: 'الحالي', en: 'Current');

  const ScopeKeys({required this.ar, required this.en});

  @override
  final String ar;
  @override
  final String en;

  @override
  String get key => 'scope.$name';
}
