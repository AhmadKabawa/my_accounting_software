import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/features/catalog/fabric_types/domain/entity/fabric_type.dart';
import 'package:accounting_software/app/features/catalog/fabric_types/presentation/localization/fabric_types_keys.dart';

AppKey fabricCategoryLabel(FabricCategory? category) => switch (category) {
  FabricCategory.knit => FabricTypesKeys.knit,
  FabricCategory.woven => FabricTypesKeys.woven,
  FabricCategory.fleece => FabricTypesKeys.fleece,
  null => FabricTypesKeys.notSpecified,
};
