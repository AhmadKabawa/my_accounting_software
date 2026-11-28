import 'package:accounting_software/app/core/foundation/validation/app_validator.dart';
import 'package:accounting_software/app/features/catalog/fabric_types/presentation/localization/fabric_types_keys.dart';

abstract final class FabricTypeFieldValidators {
  static const maxNameLength = 100;
  static const maxCodeLength = 50;
  static String? name(String? value) => AppValidator.validate(
    value,
    [ValidationRule.required, ValidationRule.maxLength],
    params: {ValidationRule.maxLength: maxNameLength},
    customKeys: {
      ValidationRule.required: FabricTypesKeys.required,
      ValidationRule.maxLength: FabricTypesKeys.nameTooLong,
    },
  );
  static String? code(String? value) => AppValidator.validate(
    value,
    [ValidationRule.required, ValidationRule.maxLength],
    params: {ValidationRule.maxLength: maxCodeLength},
    customKeys: {
      ValidationRule.required: FabricTypesKeys.required,
      ValidationRule.maxLength: FabricTypesKeys.codeTooLong,
    },
  );
}
