import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/features/catalog/materials/domain/entity/material.dart';
import 'package:accounting_software/app/features/catalog/materials/presentation/localization/materials_keys.dart';

AppKey materialTypeLabel(MaterialType? type) => switch (type) {
  MaterialType.natural => MaterialsKeys.natural,
  MaterialType.synthetic => MaterialsKeys.synthetic,
  MaterialType.blended => MaterialsKeys.blended,
  null => MaterialsKeys.notSpecified,
};
