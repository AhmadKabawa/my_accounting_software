import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:accounting_software/app/core/access/cubit/access_cubit.dart';
import 'package:accounting_software/app/core/access/permission.dart';
import 'package:accounting_software/app/routing/not_found_screen.dart';
import 'package:accounting_software/app/routing/route_guards.dart';
import 'package:accounting_software/app/features/access/presentation/routing/access_routes.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/pages/brands_screen.dart';
import 'package:accounting_software/app/features/catalog/presentation/pages/catalog_hub_screen.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/routing/brands_routes.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/pages/colors_screen.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/routing/colors_routes.dart';
import 'package:accounting_software/app/features/catalog/tags/presentation/routing/tags_routes.dart';
import 'package:accounting_software/app/features/catalog/tags/presentation/pages/tags_screen.dart';
import 'package:accounting_software/app/features/catalog/sports/presentation/routing/sports_routes.dart';
import 'package:accounting_software/app/features/catalog/genders/presentation/routing/genders_routes.dart';
import 'package:accounting_software/app/features/catalog/genders/presentation/pages/genders_screen.dart';
import 'package:accounting_software/app/features/catalog/age_groups/presentation/routing/age_groups_routes.dart';
import 'package:accounting_software/app/features/catalog/age_groups/presentation/pages/age_groups_screen.dart';
import 'package:accounting_software/app/features/catalog/sports/presentation/pages/sports_screen.dart';
import 'package:accounting_software/app/features/catalog/categories/presentation/routing/categories_routes.dart';
import 'package:accounting_software/app/features/catalog/categories/presentation/categories_list_page.dart';
import 'package:accounting_software/app/features/catalog/product_types/presentation/pages/product_types_screen.dart';
import 'package:accounting_software/app/features/catalog/product_types/presentation/pages/product_type_details_screen.dart';
import 'package:accounting_software/app/features/catalog/product_types/presentation/routing/product_types_routes.dart';
import 'package:accounting_software/app/features/catalog/units/presentation/pages/units_screen.dart';
import 'package:accounting_software/app/features/catalog/units/presentation/routing/units_routes.dart';
import 'package:accounting_software/app/features/catalog/option_sets/presentation/pages/option_sets_screen.dart';
import 'package:accounting_software/app/features/catalog/option_sets/presentation/routing/option_sets_routes.dart';
import 'package:accounting_software/app/features/catalog/attributes/presentation/pages/attributes_screen.dart';
import 'package:accounting_software/app/features/catalog/attributes/presentation/routing/attributes_routes.dart';
import 'package:accounting_software/app/features/catalog/size_systems/systems/presentation/pages/size_systems_screen.dart';
import 'package:accounting_software/app/features/catalog/size_systems/sizes/presentation/pages/sizes_screen.dart';
import 'package:accounting_software/app/features/catalog/size_systems/presentation/routing/size_systems_routes.dart';
import 'package:accounting_software/app/features/catalog/size_systems/groups/presentation/pages/size_groups_screen.dart';
import 'package:accounting_software/app/features/catalog/materials/presentation/routing/materials_routes.dart';
import 'package:accounting_software/app/features/catalog/materials/presentation/pages/materials_screen.dart';
import 'package:accounting_software/app/features/catalog/fabric_types/presentation/routing/fabric_types_routes.dart';
import 'package:accounting_software/app/features/catalog/fabric_types/presentation/pages/fabric_types_screen.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/presentation/routing/care_instructions_routes.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/presentation/pages/care_instructions_screen.dart';
import 'package:accounting_software/app/features/catalog/seasons/presentation/routing/seasons_routes.dart';
import 'package:accounting_software/app/features/catalog/seasons/presentation/pages/seasons_screen.dart';
import 'package:accounting_software/app/features/catalog/collections/presentation/routing/collections_routes.dart';
import 'package:accounting_software/app/features/catalog/collections/presentation/pages/collections_screen.dart';
import 'package:accounting_software/app/features/catalog/presentation/routing/catalog_routes.dart';

/// GoRouter registrations owned by the Catalog feature.
List<RouteBase> buildCatalogRoutes({required AccessCubit accessCubit}) => [
  GoRoute(
    path: CatalogRoutes.hub.path,
    name: CatalogRoutes.hub.name,
    redirect: (context, state) =>
        _catalogRedirect(accessCubit, context, state),
    pageBuilder: (context, state) =>
        const NoTransitionPage(child: CatalogHubScreen()),
  ),
  GoRoute(
    path: CatalogRoutes.masterData.path,
    name: CatalogRoutes.masterData.name,
    redirect: (context, state) =>
        _catalogRedirect(accessCubit, context, state) ?? catalogMasterDataRedirect(),
  ),
  GoRoute(
    path: BrandsRoutes.brands.path,
    name: BrandsRoutes.brands.name,
    redirect: _catalogRedirect,
    pageBuilder: (context, state) =>
        NoTransitionPage(child: const BrandsScreen()),
  ),
  GoRoute(
    path: UnitsRoutes.units.path,
    name: UnitsRoutes.units.name,
    redirect: _catalogRedirect,
    pageBuilder: (context, state) =>
        const NoTransitionPage(child: UnitsScreen()),
  ),
  GoRoute(
    path: OptionSetsRoutes.optionSets.path,
    name: OptionSetsRoutes.optionSets.name,
    redirect: _catalogRedirect,
    pageBuilder: (context, state) =>
        const NoTransitionPage(child: OptionSetsScreen()),
  ),
  GoRoute(
    path: AttributesRoutes.attributes.path,
    name: AttributesRoutes.attributes.name,
    redirect: _catalogRedirect,
    pageBuilder: (context, state) =>
        const NoTransitionPage(child: AttributesScreen()),
  ),
  GoRoute(
    path: SizeSystemsRoutes.sizeSystems.path,
    name: SizeSystemsRoutes.sizeSystems.name,
    redirect: _catalogRedirect,
    pageBuilder: (context, state) =>
        const NoTransitionPage(child: SizeSystemsScreen()),
  ),
  GoRoute(
    path: SizeSystemsRoutes.groupsPath,
    name: SizeSystemsRoutes.groupsName,
    redirect: _catalogRedirect,
    pageBuilder: (context, state) {
      final systemId = int.tryParse(state.pathParameters['systemId'] ?? '');
      final extra = state.extra;
      return NoTransitionPage(
        child: systemId == null
            ? NotFoundScreen(location: state.uri.toString())
            : SizeGroupsScreen(
                systemId: systemId,
                labels: extra is SizeRouteContext ? extra : null,
              ),
      );
    },
  ),
  GoRoute(
    path: SizeSystemsRoutes.sizesPath,
    name: SizeSystemsRoutes.sizesName,
    redirect: _catalogRedirect,
    pageBuilder: (context, state) {
      final systemId = int.tryParse(state.pathParameters['systemId'] ?? '');
      final groupId = int.tryParse(state.pathParameters['groupId'] ?? '');
      final extra = state.extra;
      return NoTransitionPage(
        child: systemId == null || groupId == null
            ? NotFoundScreen(location: state.uri.toString())
            : SizesScreen(
                systemId: systemId,
                groupId: groupId,
                labels: extra is SizeRouteContext ? extra : null,
              ),
      );
    },
  ),
  GoRoute(
    path: CategoriesRoutes.categories.path,
    name: CategoriesRoutes.categories.name,
    redirect: _catalogRedirect,
    pageBuilder: (context, state) =>
        const NoTransitionPage(child: CategoriesListPage()),
  ),
  GoRoute(
    path: ProductTypesRoutes.productTypes.path,
    name: ProductTypesRoutes.productTypes.name,
    redirect: _catalogRedirect,
    pageBuilder: (context, state) =>
        const NoTransitionPage(child: ProductTypesScreen()),
  ),
  GoRoute(
    path: ProductTypesRoutes.detailsPath,
    name: ProductTypesRoutes.productTypeDetails.name,
    redirect: _catalogRedirect,
    pageBuilder: (context, state) {
      final id = int.tryParse(state.pathParameters['id'] ?? '');
      return NoTransitionPage(
        child: id == null
            ? NotFoundScreen(location: state.uri.toString())
            : ProductTypeDetailsScreen(productTypeId: id),
      );
    },
  ),
  GoRoute(
    path: ColorsRoutes.colors.path,
    name: ColorsRoutes.colors.name,
    redirect: _catalogRedirect,
    pageBuilder: (context, state) =>
        const NoTransitionPage(child: ColorsScreen()),
  ),
  GoRoute(
    path: TagsRoutes.tags.path,
    name: TagsRoutes.tags.name,
    redirect: _catalogRedirect,
    pageBuilder: (context, state) =>
        const NoTransitionPage(child: TagsScreen()),
  ),
  GoRoute(
    path: GendersRoutes.genders.path,
    name: GendersRoutes.genders.name,
    redirect: _catalogRedirect,
    pageBuilder: (context, state) =>
        const NoTransitionPage(child: GendersScreen()),
  ),
  GoRoute(
    path: AgeGroupsRoutes.ageGroups.path,
    name: AgeGroupsRoutes.ageGroups.name,
    redirect: _catalogRedirect,
    pageBuilder: (context, state) =>
        const NoTransitionPage(child: AgeGroupsScreen()),
  ),
  GoRoute(
    path: MaterialsRoutes.materials.path,
    name: MaterialsRoutes.materials.name,
    redirect: _catalogRedirect,
    pageBuilder: (context, state) =>
        const NoTransitionPage(child: MaterialsScreen()),
  ),
  GoRoute(
    path: FabricTypesRoutes.fabricTypes.path,
    name: FabricTypesRoutes.fabricTypes.name,
    redirect: _catalogRedirect,
    pageBuilder: (context, state) =>
        const NoTransitionPage(child: FabricTypesScreen()),
  ),
  GoRoute(
    path: CareInstructionsRoutes.careInstructions.path,
    name: CareInstructionsRoutes.careInstructions.name,
    redirect: _catalogRedirect,
    pageBuilder: (context, state) =>
        const NoTransitionPage(child: CareInstructionsScreen()),
  ),
  GoRoute(
    path: SeasonsRoutes.seasons.path,
    name: SeasonsRoutes.seasons.name,
    redirect: _catalogRedirect,
    pageBuilder: (context, state) =>
        const NoTransitionPage(child: SeasonsScreen()),
  ),
  GoRoute(
    path: CollectionsRoutes.collections.path,
    name: CollectionsRoutes.collections.name,
    redirect: _catalogRedirect,
    pageBuilder: (context, state) =>
        const NoTransitionPage(child: CollectionsScreen()),
  ),
  GoRoute(
    path: SportsRoutes.sports.path,
    name: SportsRoutes.sports.name,
    redirect: _catalogRedirect,
    pageBuilder: (context, state) =>
        const NoTransitionPage(child: SportsScreen()),
  ),
];

String? _catalogRedirect(
  AccessCubit accessCubit,
  BuildContext context,
  GoRouterState state,
) => AccessRoutingLogic.require(
  const Permission('catalog.manage'),
  can: accessCubit.can,
  isResolved: () =>
      accessCubit.state.status != AccessStatus.initial &&
      accessCubit.state.status != AccessStatus.loading,
  fallback: AccessRoutes.denied,
)(context, state);
