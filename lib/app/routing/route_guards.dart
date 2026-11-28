import 'package:go_router/go_router.dart';
import 'package:accounting_software/app/core/access/permission.dart';
import 'package:accounting_software/app/core/foundation/config/app_config.dart';
import 'package:accounting_software/app/routing/app_go_router.dart';
import 'package:accounting_software/app/core/routing/route_item.dart';
import 'package:accounting_software/app/features/auth/domain/session/session_gate.dart';
import 'package:accounting_software/app/features/auth/presentation/routing/auth_routes.dart';
import 'package:accounting_software/app/features/home/presentation/routing/home_routes.dart';
import 'package:accounting_software/app/features/on_boarding/presentation/routing/on_boarding_routes.dart';
import 'package:accounting_software/app/features/profile/presentation/routing/profile_routes.dart';
import 'package:accounting_software/app/features/splash/presentation/routing/splash_routes.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/routing/brands_routes.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/routing/colors_routes.dart';
import 'package:accounting_software/app/features/catalog/tags/presentation/routing/tags_routes.dart';
import 'package:accounting_software/app/features/catalog/sports/presentation/routing/sports_routes.dart';
import 'package:accounting_software/app/features/catalog/units/presentation/routing/units_routes.dart';
import 'package:accounting_software/app/features/catalog/option_sets/presentation/routing/option_sets_routes.dart';
import 'package:accounting_software/app/features/catalog/attributes/presentation/routing/attributes_routes.dart';
import 'package:accounting_software/app/features/catalog/product_types/presentation/routing/product_types_routes.dart';
import 'package:accounting_software/app/features/catalog/presentation/routing/catalog_routes.dart';
import 'package:accounting_software/app/features/catalog/categories/presentation/routing/categories_routes.dart';
import 'package:accounting_software/app/features/catalog/genders/presentation/routing/genders_routes.dart';
import 'package:accounting_software/app/features/catalog/age_groups/presentation/routing/age_groups_routes.dart';
import 'package:accounting_software/app/features/catalog/materials/presentation/routing/materials_routes.dart';
import 'package:accounting_software/app/features/catalog/fabric_types/presentation/routing/fabric_types_routes.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/presentation/routing/care_instructions_routes.dart';
import 'package:accounting_software/app/features/catalog/seasons/presentation/routing/seasons_routes.dart';
import 'package:accounting_software/app/features/catalog/collections/presentation/routing/collections_routes.dart';
import 'package:accounting_software/app/features/catalog/size_systems/presentation/routing/size_systems_routes.dart';

Set<String> buildPublicRoutes({
  bool signupEnabled = AppConfig.signupEnabled,
  bool forgotPasswordEnabled = AppConfig.forgotPasswordEnabled,
  bool onboardingEnabled = AppConfig.onboardingEnabled,
}) => {
  SplashRoutes.splash.path,
  if (onboardingEnabled) OnBoardingRoutes.onboarding.path,
  AuthRoutes.login.path,
  if (signupEnabled) AuthRoutes.register.path,
  if (forgotPasswordEnabled) ...[
    AuthRoutes.forgotPassword.path,
    AuthRoutes.resetPassword.path,
  ],
};

final Set<String> publicRoutes = buildPublicRoutes();

final Set<String> protectedRoutes = {
  AuthRoutes.selectBranch.path,
  AuthRoutes.changePassword.path,
  HomeRoutes.home.path,
  ProfileRoutes.profile.path,
  BrandsRoutes.brands.path,
  ColorsRoutes.colors.path,
  CategoriesRoutes.categories.path,
  GendersRoutes.genders.path,
  AgeGroupsRoutes.ageGroups.path,
  TagsRoutes.tags.path,
  SportsRoutes.sports.path,
  UnitsRoutes.units.path,
  OptionSetsRoutes.optionSets.path,
  AttributesRoutes.attributes.path,
  SizeSystemsRoutes.sizeSystems.path,
  SizeSystemsRoutes.groupsPath,
  SizeSystemsRoutes.sizesPath,
  ProductTypesRoutes.productTypes.path,
  MaterialsRoutes.materials.path,
  FabricTypesRoutes.fabricTypes.path,
  CareInstructionsRoutes.careInstructions.path,
  SeasonsRoutes.seasons.path,
  CollectionsRoutes.collections.path,
  CatalogRoutes.hub.path,
  CatalogRoutes.masterData.path,
};

/// Pure navigation policy. A forced password change is evaluated before
/// branch selection and before every other authenticated destination.
String? resolveRedirect({
  required String location,
  required bool splashDone,
  required bool onboarded,
  required SessionStatus session,
  bool mustChangePassword = false,
  bool branchSelectionRequired = false,
  bool onboardingEnabled = AppConfig.onboardingEnabled,
  bool signupEnabled = AppConfig.signupEnabled,
  bool forgotPasswordEnabled = AppConfig.forgotPasswordEnabled,
}) {
  final splash = SplashRoutes.splash.path;
  final onboarding = OnBoardingRoutes.onboarding.path;
  final login = AuthRoutes.login.path;
  final home = HomeRoutes.home.path;
  final changePassword = AuthRoutes.changePassword.path;
  final selectBranch = AuthRoutes.selectBranch.path;

  final disabledRoutes = {
    if (!signupEnabled) AuthRoutes.register.path,
    if (!forgotPasswordEnabled) ...[
      AuthRoutes.forgotPassword.path,
      AuthRoutes.resetPassword.path,
    ],
    if (!onboardingEnabled) OnBoardingRoutes.onboarding.path,
  };
  if (disabledRoutes.contains(location)) return null;
  if (!splashDone) return location == splash ? null : splash;
  if (session is SessionChecking) return null;

  final authenticated = session is SessionAuthenticated;
  if (authenticated && mustChangePassword) {
    return location == changePassword ? null : changePassword;
  }
  if (authenticated && location == changePassword) {
    return branchSelectionRequired ? selectBranch : home;
  }

  if (location == splash) {
    if (onboardingEnabled && !onboarded) return onboarding;
    if (!authenticated) return login;
    return branchSelectionRequired ? selectBranch : home;
  }

  if (onboardingEnabled && !onboarded) {
    return location == onboarding ? null : onboarding;
  }

  if (authenticated) {
    if (branchSelectionRequired) {
      return location == selectBranch ? null : selectBranch;
    }
    if (location == selectBranch) return home;
    final authEntryRoutes = {
      AuthRoutes.login.path,
      if (signupEnabled) AuthRoutes.register.path,
    };
    return authEntryRoutes.contains(location) ? home : null;
  }

  final enabledPublicRoutes = buildPublicRoutes(
    signupEnabled: signupEnabled,
    forgotPasswordEnabled: forgotPasswordEnabled,
    onboardingEnabled: onboardingEnabled,
  );
  return enabledPublicRoutes.contains(location) ? null : login;
}

/// UX-only permission routing. The database remains the security boundary.
abstract class AccessRoutingLogic {
  static GoRouterRedirect require(
    Permission permission, {
    RouteItem fallback = HomeRoutes.home,
  }) =>
      (context, state) =>
          AppRouter.accessCubit.can(permission) ? null : fallback.path;
}
