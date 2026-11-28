import 'package:accounting_software/app/core/foundation/validation/app_validator.dart';
import 'package:accounting_software/app/features/catalog/seasons/presentation/localization/seasons_keys.dart';

abstract final class SeasonFieldValidators {
  static const maxNameLength = 100;
  static const maxCodeLength = 50;
  static String? name(String? value) => AppValidator.validate(
    value,
    [ValidationRule.required, ValidationRule.maxLength],
    params: {ValidationRule.maxLength: maxNameLength},
    customKeys: {
      ValidationRule.required: SeasonsKeys.required,
      ValidationRule.maxLength: SeasonsKeys.nameTooLong,
    },
  );
  static String? code(String? value) => AppValidator.validate(
    value,
    [ValidationRule.required, ValidationRule.maxLength],
    params: {ValidationRule.maxLength: maxCodeLength},
    customKeys: {
      ValidationRule.required: SeasonsKeys.required,
      ValidationRule.maxLength: SeasonsKeys.codeTooLong,
    },
  );
}
