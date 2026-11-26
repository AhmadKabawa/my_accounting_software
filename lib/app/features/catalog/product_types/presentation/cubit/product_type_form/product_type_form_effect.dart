import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/entity/product_type.dart';

sealed class ProductTypeFormEffect {
  const ProductTypeFormEffect();
}

final class ProductTypeSavedEffect extends ProductTypeFormEffect {
  const ProductTypeSavedEffect(this.productType);

  final ProductType productType;
}

final class ProductTypeSaveFailedEffect extends ProductTypeFormEffect {
  const ProductTypeSaveFailedEffect(this.messageKey);

  final AppKey messageKey;
}
