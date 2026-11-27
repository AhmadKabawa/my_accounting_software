import 'package:accounting_software/app/core/foundation/validation/app_validator.dart';
import 'package:accounting_software/app/core/foundation/validation/slug.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/localization/brands_keys.dart';

/// Brand form rules, built on the shared [AppValidator] (the project's single
/// validation system). Limits mirror the `brands` table; only the messages are
/// brand-specific.
abstract final class BrandFieldValidators {
  static const maxName = 150;
  static const maxSlug = 150;

  static String? name(String? value) => AppValidator.validate(
    value,
    [ValidationRule.required, ValidationRule.maxLength],
    params: {ValidationRule.maxLength: maxName},
    customKeys: {
      ValidationRule.required: BrandsKeys.required,
      ValidationRule.maxLength: BrandsKeys.nameTooLong,
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
      ValidationRule.required: BrandsKeys.slugRequired,
      ValidationRule.maxLength: BrandsKeys.slugTooLong,
      ValidationRule.pattern: BrandsKeys.slugFormat,
    },
  );
}
