import 'package:accounting_software/app/features/catalog/presentation/localization/catalog_hub_keys.dart';
import 'package:accounting_software/app/core/access/keys/access_keys.dart';
import 'package:accounting_software/app/core/localization/keys/common_keys.dart';
import 'package:accounting_software/app/core/localization/keys/catalog_ui_keys.dart';
import 'package:accounting_software/app/core/localization/keys/badge_keys.dart';
import 'package:accounting_software/app/core/localization/keys/dialog_keys.dart';
import 'package:accounting_software/app/core/localization/keys/erp_error_keys.dart';
import 'package:accounting_software/app/core/localization/keys/error_keys.dart';
import 'package:accounting_software/app/core/localization/keys/field_keys.dart';
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
import 'package:accounting_software/app/features/catalog/brands/presentation/localization/brands_keys.dart';

final List<AppKey> allKeys = <AppKey>[
  ...CommonKeys.values,
  ...CatalogUiKeys.values,
  ...BadgeKeys.values,
  ...DialogKeys.values,
  ...ScopeKeys.values,
  ...ShellKeys.values,
  ...TemplateKeys.values,
  ...FieldKeys.values,
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
  ...CatalogHubKeys.values,
  ...HomeKeys.values,
  ...OnboardingKeys.values,
];
