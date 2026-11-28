import 'package:accounting_software/app/core/foundation/config/app_config.dart';
import 'package:accounting_software/app/features/access/presentation/routing/access_routes.dart';
import 'package:accounting_software/app/core/routing/route_item.dart';
import 'package:accounting_software/app/features/auth/presentation/routing/auth_routes.dart';
import 'package:accounting_software/app/features/home/presentation/routing/home_routes.dart';
import 'package:accounting_software/app/features/on_boarding/presentation/routing/on_boarding_routes.dart';
import 'package:accounting_software/app/features/profile/presentation/routing/profile_routes.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/routing/brands_routes.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/routing/colors_routes.dart';
import 'package:accounting_software/app/features/catalog/sports/presentation/routing/sports_routes.dart';
import 'package:accounting_software/app/features/catalog/genders/presentation/routing/genders_routes.dart';
import 'package:accounting_software/app/features/catalog/age_groups/presentation/routing/age_groups_routes.dart';
import 'package:accounting_software/app/features/catalog/tags/presentation/routing/tags_routes.dart';
import 'package:accounting_software/app/features/catalog/presentation/routing/catalog_routes.dart';
import 'package:accounting_software/app/features/catalog/categories/presentation/routing/categories_routes.dart';
import 'package:accounting_software/app/features/catalog/units/presentation/routing/units_routes.dart';
import 'package:accounting_software/app/features/catalog/option_sets/presentation/routing/option_sets_routes.dart';
import 'package:accounting_software/app/features/catalog/attributes/presentation/routing/attributes_routes.dart';
import 'package:accounting_software/app/features/catalog/size_systems/presentation/routing/size_systems_routes.dart';
import 'package:accounting_software/app/features/catalog/product_types/presentation/routing/product_types_routes.dart';
import 'package:accounting_software/app/features/catalog/materials/presentation/routing/materials_routes.dart';
import 'package:accounting_software/app/features/catalog/fabric_types/presentation/routing/fabric_types_routes.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/presentation/routing/care_instructions_routes.dart';
import 'package:accounting_software/app/features/catalog/seasons/presentation/routing/seasons_routes.dart';
import 'package:accounting_software/app/features/catalog/collections/presentation/routing/collections_routes.dart';
import 'package:accounting_software/app/features/splash/presentation/routing/splash_routes.dart';

/// Build the route catalogue for the selected feature flags. Disabled
/// features are absent from the registry, not merely hidden in the UI.
List<RouteItem> buildRouteRegistry({
  bool signupEnabled = AppConfig.signupEnabled,
  bool forgotPasswordEnabled = AppConfig.forgotPasswordEnabled,
  bool onboardingEnabled = AppConfig.onboardingEnabled,
}) => [
  ...SplashRoutes.all,
  ...AccessRoutes.all,
  ...OnBoardingRoutes.all(enabled: onboardingEnabled),
  AuthRoutes.login,
  AuthRoutes.changePassword,
  AuthRoutes.selectBranch,
  if (signupEnabled) AuthRoutes.register,
  if (forgotPasswordEnabled) ...[
    AuthRoutes.forgotPassword,
    AuthRoutes.resetPassword,
  ],
  ...HomeRoutes.all,
  ...ProfileRoutes.all,
  ...CatalogRoutes.all,
  ...BrandsRoutes.all,
  ...ColorsRoutes.all,
  ...CategoriesRoutes.all,
  ...TagsRoutes.all,
  ...SportsRoutes.all,
  ...GendersRoutes.all,
  ...AgeGroupsRoutes.all,
  ...ProductTypesRoutes.all,
  ...MaterialsRoutes.all,
  ...FabricTypesRoutes.all,
  ...CareInstructionsRoutes.all,
  ...SeasonsRoutes.all,
  ...CollectionsRoutes.all,
  ...UnitsRoutes.all,
  ...OptionSetsRoutes.all,
  ...AttributesRoutes.all,
  ...SizeSystemsRoutes.all,
];

/// Every GoRouter destination, including dynamic detail paths that are not
/// home-dashboard destinations.
List<RouteItem> buildRegisteredRouteRegistry({
  bool signupEnabled = AppConfig.signupEnabled,
  bool forgotPasswordEnabled = AppConfig.forgotPasswordEnabled,
  bool onboardingEnabled = AppConfig.onboardingEnabled,
}) => [
  ...buildRouteRegistry(
    signupEnabled: signupEnabled,
    forgotPasswordEnabled: forgotPasswordEnabled,
    onboardingEnabled: onboardingEnabled,
  ),
  RouteItem(
    ProductTypesRoutes.detailsPath,
    ProductTypesRoutes.productTypeDetailsName,
  ),
  RouteItem(SizeSystemsRoutes.groupsPath, SizeSystemsRoutes.groupsName),
  RouteItem(SizeSystemsRoutes.sizesPath, SizeSystemsRoutes.sizesName),
];

/// Stable destinations offered by the home dashboard (dynamic detail routes
/// are intentionally excluded).
final List<RouteItem> allRoutes = buildRouteRegistry();

/// Complete route registry used by routing guards and classification.
final List<RouteItem> registeredRoutes = buildRegisteredRouteRegistry();
