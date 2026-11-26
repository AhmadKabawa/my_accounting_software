import 'package:accounting_software/app/core/foundation/validation/app_validator.dart';
import 'package:accounting_software/app/core/foundation/validation/slug.dart';
import 'package:accounting_software/app/features/catalog/tags/presentation/localization/tags_keys.dart';

/// Tag form rules on the shared [AppValidator]. Limits mirror the `tags`
/// table (`name` and `slug` are both varchar(100) and UNIQUE).
abstract final class TagFieldValidators {
  static const maxName = 100;
  static const maxSlug = 100;

  static String? name(String? value) => AppValidator.validate(
    value,
    [ValidationRule.required, ValidationRule.maxLength],
    params: {ValidationRule.maxLength: maxName},
    customKeys: {
      ValidationRule.required: TagsKeys.required,
      ValidationRule.maxLength: TagsKeys.nameTooLong,
    },
  );

  static String? slug(String? value) => AppValidator.validate(
    value,
    [ValidationRule.required, ValidationRule.maxLength, ValidationRule.pattern],
    params: {
      ValidationRule.maxLength: maxSlug,
      ValidationRule.pattern: Slug.pattern,
    },
    customKeys: {
      ValidationRule.required: TagsKeys.required,
      ValidationRule.maxLength: TagsKeys.slugTooLong,
      ValidationRule.pattern: TagsKeys.slugFormat,
    },
  );
}
