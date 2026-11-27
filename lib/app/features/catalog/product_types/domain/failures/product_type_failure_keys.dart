import 'package:accounting_software/app/core/localization/translations/app_key.dart';

enum ProductTypeFailureKeys implements AppKey {
  inUse(
    ar: 'لا يمكن حذف نوع المنتج لوجود منتجات أو ارتباطات تستخدمه. أوقفه بدلاً من ذلك.',
    en: 'This product type is referenced by products or linked settings. Deactivate it instead.',
  ),
  usageUnknown(
    ar: 'تعذر التحقق من ارتباطات نوع المنتج؛ لا يمكن حذفه بأمان.',
    en: 'Product type usage could not be verified, so it cannot be safely deleted.',
  ),
  duplicate(
    ar: 'رمز نوع المنتج مستخدم مسبقاً. اختر رمزاً آخر.',
    en: 'This product type code is already in use. Choose another code.',
  ),
  defaultSizeGroupConflict(
    ar: 'توجد مجموعة مقاسات افتراضية أخرى لهذا النوع والجنس.',
    en: 'Another default size group already exists for this product type and gender.',
  );

  const ProductTypeFailureKeys({required this.ar, required this.en});
  @override
  final String ar;
  @override
  final String en;
  @override
  String get key => 'producttypefailures.$name';
}
