import 'package:accounting_software/app/features/catalog/presentation/localization/catalog_hub_keys.dart';
import 'package:accounting_software/app/core/access/keys/access_keys.dart';
import 'package:accounting_software/app/core/localization/keys/common_keys.dart';
import 'package:accounting_software/app/core/localization/keys/catalog_ui_keys.dart';
import 'package:accounting_software/app/core/localization/keys/badge_keys.dart';
import 'package:accounting_software/app/core/localization/keys/dialog_keys.dart';
import 'package:accounting_software/app/core/localization/keys/erp_error_keys.dart';
import 'package:accounting_software/app/core/localization/keys/error_keys.dart';
import 'package:accounting_software/app/core/localization/keys/field_keys.dart';
import 'package:accounting_software/app/core/localization/keys/image_keys.dart';
import 'package:accounting_software/app/core/localization/keys/message_keys.dart';
import 'package:accounting_software/app/core/localization/keys/nav_keys.dart';
import 'package:accounting_software/app/core/localization/keys/scope_keys.dart';
import 'package:accounting_software/app/core/localization/keys/shell_keys.dart';
import 'package:accounting_software/app/core/localization/keys/template_keys.dart';
import 'package:accounting_software/app/core/localization/keys/server_error_keys.dart';
import 'package:accounting_software/app/core/localization/keys/theme_keys.dart';
import 'package:accounting_software/app/core/localization/keys/validation_keys.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/features/auth/presentation/localization/auth_keys.dart';
import 'package:accounting_software/app/features/home/presentation/localization/home_keys.dart';
import 'package:accounting_software/app/features/on_boarding/presentation/localization/onboarding_keys.dart';
import 'package:accounting_software/app/features/profile/presentation/localization/profile_keys.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/failures/brand_failure_keys.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/localization/brands_keys.dart';
// [cat08:begin] CAT-08 feature and failure translations.
import 'package:accounting_software/app/features/catalog/units/presentation/localization/units_keys.dart';
import 'package:accounting_software/app/features/catalog/units/domain/failures/unit_failure_keys.dart';
import 'package:accounting_software/app/features/catalog/option_sets/presentation/localization/option_sets_keys.dart';
import 'package:accounting_software/app/features/catalog/attributes/presentation/localization/attributes_keys.dart';
// [cat08:end]
import 'package:accounting_software/app/features/catalog/categories/domain/failures/category_failure_keys.dart';
import 'package:accounting_software/app/features/catalog/categories/presentation/localization/categories_keys.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/localization/colors_keys.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/failures/color_failure_keys.dart';
import 'package:accounting_software/app/core/foundation/color/color_name_keys.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_color_picker/app_color_picker_keys.dart';

final List<AppKey> allKeys = <AppKey>[
  ...CommonKeys.values,
  ...CatalogUiKeys.values,
  ...BadgeKeys.values,
  ...DialogKeys.values,
  ...ScopeKeys.values,
  ...ShellKeys.values,
  ...TemplateKeys.values,
  ...FieldKeys.values,
  ...ImageKeys.values,
  ...ValidationKeys.values,
  ...ErrorKeys.values,
  ...ServerErrorKeys.values,
  ...ErpErrorKeys.values,
  ...ThemeKeys.values,
  ...NavKeys.values,
  ...MessageKeys.values,
  ...AccessKeys.values,
  ...AuthKeys.values,
  ...ProfileKeys.values,
  ...BrandsKeys.values,
  // [cat08:begin] CAT-08 feature and failure translations.
  ...UnitsKeys.values,
  ...UnitFailureKeys.values,
  ...OptionSetsKeys.values,
  ...AttributesKeys.values,
  // [cat08:end]
  ...CategoriesKeys.values,
  ...CategoryFailureKeys.values,
  ...ColorsKeys.values,
  ...ColorFailureKeys.values,
  ...ColorNameKeys.values,
  ...AppColorPickerKeys.values,
  ...BrandFailureKeys.values,
  ...CatalogHubKeys.values,
  ...HomeKeys.values,
  ...OnboardingKeys.values,
];
