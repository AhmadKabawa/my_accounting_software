import 'package:accounting_software/app/core/localization/translations/app_key.dart';

/// Messages of the brand domain failures.
///
/// They live in the domain (not in `BrandsKeys`) so that `domain/` never
/// imports from `presentation/`.
enum BrandFailureKeys implements AppKey {
  brandUsageUnknown(
    ar: 'تعذر التحقق من ارتباط المنتجات بهذه العلامة',
    en: 'Could not verify whether products are linked to this brand.',
  ),
  brandInUse(
    ar: 'لا يمكن حذف الماركة لأنها مرتبطة بمنتجات. يمكنك إيقافها بدلاً من ذلك.',
    en: 'This brand cannot be deleted because products reference it. Deactivate it instead.',
  );

  const BrandFailureKeys({required this.ar, required this.en});
  @override
  final String ar;
  @override
  final String en;
  @override
  String get key => 'brands.$name';
}
