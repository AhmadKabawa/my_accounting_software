import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/features/catalog/size_systems/sizes/domain/entity/catalog_size.dart';

sealed class SizeFormEffect {
  const SizeFormEffect();
}

class SizeSavedEffect extends SizeFormEffect {
  const SizeSavedEffect(this.size);
  final CatalogSize size;
}

class SizeSaveFailedEffect extends SizeFormEffect {
  const SizeSaveFailedEffect(this.messageKey);
  final AppKey messageKey;
}
