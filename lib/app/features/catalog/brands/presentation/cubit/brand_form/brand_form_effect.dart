import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand.dart';

sealed class BrandFormEffect {
  const BrandFormEffect();
}

class BrandSavedEffect extends BrandFormEffect {
  const BrandSavedEffect(this.brand);

  final Brand brand;
}

class BrandSaveFailedEffect extends BrandFormEffect {
  const BrandSaveFailedEffect(this.messageKey);

  final AppKey messageKey;
}
