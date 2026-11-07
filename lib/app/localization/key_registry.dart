import 'package:accounting_software/app/core/localization/keys/common_keys.dart';
import 'package:accounting_software/app/core/localization/keys/error_keys.dart';
import 'package:accounting_software/app/core/localization/keys/field_keys.dart';
import 'package:accounting_software/app/core/localization/keys/nav_keys.dart';
import 'package:accounting_software/app/core/localization/keys/server_error_keys.dart';
import 'package:accounting_software/app/core/localization/keys/theme_keys.dart';
import 'package:accounting_software/app/core/localization/keys/validation_keys.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/features/auth/presentation/localization/auth_keys.dart';
import 'package:accounting_software/app/features/home/presentation/localization/home_keys.dart';
import 'package:accounting_software/app/features/on_boarding/presentation/localization/onboarding_keys.dart';
import 'package:accounting_software/app/features/profile/presentation/localization/profile_keys.dart';

/// Every translatable text in the app. Composition root: lives outside `core`
/// so `core` does not depend on `features`.
///
/// Adding a feature section = one line here. A guard test
/// (`test/localization/key_registry_test.dart`) fails if an
/// `enum X implements AppKey` is not registered.
final List<AppKey> allKeys = <AppKey>[
  // core
  ...CommonKeys.values,
  ...FieldKeys.values,
  ...ValidationKeys.values,
  ...ErrorKeys.values,
  ...ServerErrorKeys.values,
  ...ThemeKeys.values,
  ...NavKeys.values,
  // features
  ...AuthKeys.values,
  ...ProfileKeys.values,
  ...HomeKeys.values,
  ...OnboardingKeys.values,
];
