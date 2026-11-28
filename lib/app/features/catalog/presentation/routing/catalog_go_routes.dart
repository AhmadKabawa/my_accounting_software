import 'package:go_router/go_router.dart';
import 'package:accounting_software/app/core/access/cubit/access_cubit.dart';
import 'package:accounting_software/app/features/catalog/presentation/routing/catalog_feature_go_routes.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/routing/brands_go_routes.dart';
import 'package:accounting_software/app/features/catalog/units/presentation/routing/units_go_routes.dart';
import 'package:accounting_software/app/features/catalog/option_sets/presentation/routing/option_sets_go_routes.dart';
import 'package:accounting_software/app/features/catalog/attributes/presentation/routing/attributes_go_routes.dart';
import 'package:accounting_software/app/features/catalog/size_systems/presentation/routing/size_systems_go_routes.dart';
import 'package:accounting_software/app/features/catalog/categories/presentation/routing/categories_go_routes.dart';
import 'package:accounting_software/app/features/catalog/product_types/presentation/routing/product_types_go_routes.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/routing/colors_go_routes.dart';
import 'package:accounting_software/app/features/catalog/tags/presentation/routing/tags_go_routes.dart';
import 'package:accounting_software/app/features/catalog/genders/presentation/routing/genders_go_routes.dart';
import 'package:accounting_software/app/features/catalog/age_groups/presentation/routing/age_groups_go_routes.dart';
import 'package:accounting_software/app/features/catalog/materials/presentation/routing/materials_go_routes.dart';
import 'package:accounting_software/app/features/catalog/fabric_types/presentation/routing/fabric_types_go_routes.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/presentation/routing/care_instructions_go_routes.dart';
import 'package:accounting_software/app/features/catalog/seasons/presentation/routing/seasons_go_routes.dart';
import 'package:accounting_software/app/features/catalog/collections/presentation/routing/collections_go_routes.dart';
import 'package:accounting_software/app/features/catalog/sports/presentation/routing/sports_go_routes.dart';

/// Aggregates the Catalog sub-feature route modules without owning routes.
List<RouteBase> buildCatalogRoutes({required AccessCubit accessCubit}) => [
  ...buildCatalogFeatureGoRoutes(accessCubit: accessCubit),
  ...buildBrandsGoRoutes(accessCubit: accessCubit),
  ...buildUnitsGoRoutes(accessCubit: accessCubit),
  ...buildOptionSetsGoRoutes(accessCubit: accessCubit),
  ...buildAttributesGoRoutes(accessCubit: accessCubit),
  ...buildSizeSystemsGoRoutes(accessCubit: accessCubit),
  ...buildCategoriesGoRoutes(accessCubit: accessCubit),
  ...buildProductTypesGoRoutes(accessCubit: accessCubit),
  ...buildColorsGoRoutes(accessCubit: accessCubit),
  ...buildTagsGoRoutes(accessCubit: accessCubit),
  ...buildGendersGoRoutes(accessCubit: accessCubit),
  ...buildAgeGroupsGoRoutes(accessCubit: accessCubit),
  ...buildMaterialsGoRoutes(accessCubit: accessCubit),
  ...buildFabricTypesGoRoutes(accessCubit: accessCubit),
  ...buildCareInstructionsGoRoutes(accessCubit: accessCubit),
  ...buildSeasonsGoRoutes(accessCubit: accessCubit),
  ...buildCollectionsGoRoutes(accessCubit: accessCubit),
  ...buildSportsGoRoutes(accessCubit: accessCubit),
];
