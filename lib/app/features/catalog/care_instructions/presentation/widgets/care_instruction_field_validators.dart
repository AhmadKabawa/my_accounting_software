import 'package:accounting_software/app/core/foundation/validation/app_validator.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/presentation/localization/care_instructions_keys.dart';

abstract final class CareInstructionFieldValidators {
  static const maxNameLength = 150;
  static const maxCodeLength = 50;

  static String? name(String? value) => AppValidator.validate(
    value,
    [ValidationRule.required, ValidationRule.maxLength],
    params: {ValidationRule.maxLength: maxNameLength},
    customKeys: {
      ValidationRule.required: CareInstructionsKeys.required,
      ValidationRule.maxLength: CareInstructionsKeys.nameTooLong,
    },
  );

  static String? code(String? value) => AppValidator.validate(
    value,
    [ValidationRule.required, ValidationRule.maxLength],
    params: {ValidationRule.maxLength: maxCodeLength},
    customKeys: {
      ValidationRule.required: CareInstructionsKeys.required,
      ValidationRule.maxLength: CareInstructionsKeys.codeTooLong,
    },
  );
}
