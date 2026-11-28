import 'package:accounting_software/app/core/localization/translations/app_key.dart';

enum CollectionFailureKeys implements AppKey {
  inUse(
    ar: 'المجموعة مرتبطة بمنتجات؛ أوقفها بدلاً من حذفها.',
    en: 'This collection is linked to products; deactivate it instead.',
  );

  const CollectionFailureKeys({required this.ar, required this.en});
  @override
  final String ar;
  @override
  final String en;
  @override
  String get key => 'catalog.collections.collectionFailure.$name';
}
