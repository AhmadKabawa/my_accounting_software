import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:accounting_software/app/core/access/permissions.dart';
import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/core/localization/keys/nav_keys.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_breadcrumb/app_breadcrumb.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_view/app_view_mode.dart';
import 'package:accounting_software/app/features/catalog/product_types/presentation/cubit/product_type_stats/product_type_stats_cubit.dart';
import 'package:accounting_software/app/features/catalog/product_types/presentation/cubit/product_type_stats/product_type_stats_state.dart';
import 'package:accounting_software/app/features/catalog/product_types/presentation/widgets/product_type_stats_bar.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_filter_bar/filter_bar.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_list_config.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_flows_config.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_labels.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/entity/product_type.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/entity/product_type_list_query.dart';
import 'package:accounting_software/app/features/catalog/product_types/presentation/cubit/product_types_list/product_types_list_cubit.dart';
import 'package:accounting_software/app/features/catalog/product_types/presentation/cubit/product_types_list/product_types_list_effect.dart';
import 'package:accounting_software/app/features/catalog/product_types/presentation/dialogs/product_type_editor_launcher.dart';
import 'package:accounting_software/app/features/catalog/product_types/presentation/localization/product_types_keys.dart';
import 'package:accounting_software/app/features/catalog/product_types/presentation/routing/product_types_routes.dart';
import 'package:accounting_software/app/features/catalog/product_types/presentation/widgets/product_types_data_section.dart';
import 'package:accounting_software/app/features/catalog/product_types/presentation/widgets/product_types_filter_bar.dart';
import 'package:accounting_software/app/features/catalog/presentation/routing/catalog_routes.dart';

const _labels = CrudLabels(
  edit: ProductTypesKeys.edit,
  delete: ProductTypesKeys.delete,
  activate: ProductTypesKeys.activate,
  deactivate: ProductTypesKeys.deactivate,
  deleteConfirmationTitle: ProductTypesKeys.deleteTitle,
  deleteConfirmationMessage: ProductTypesKeys.deleteMessage,
  deactivateConfirmationTitle: ProductTypesKeys.deactivateTitle,
  deactivateConfirmationMessage: ProductTypesKeys.deactivateMessage,
);

CrudListConfig<ProductType, ProductTypeListQuery, ProductTypesListCubit,
    ProductTypesListEffect> get productTypesListConfig => CrudListConfig(
  screenId: 'catalog.productTypes',
  titleKey: ProductTypesKeys.title,
  manageAccess: Permissions.masterData.manage,
  searchHintKey: ProductTypesKeys.searchHint,
  addLabelKey: ProductTypesKeys.add,
  createCubit: () => sl<ProductTypesListCubit>(),
  rowId: (item) => item.id,
  itemLabel: (item) => item.name,
  sort: CrudSortConfig<ProductTypeListQuery, ProductTypesListCubit>(
    options: const [],
    current: (_) => const [],
    tableKey: (_) => null,
    tableAscending: (_) => true,
    apply: (_, __) {},
    applyTable: (_, __) {},
  ),
  filterControls: (slot) => ProductTypesFilterBar.controls(
    slot.context,
    slot.state.query,
    onStatusChanged: slot.cubit.setStatus,
  ),
  activeFilters: (slot) => ProductTypesFilterBar.activeFilters(
    slot.context,
    slot.state.query,
    onSearchChanged: slot.cubit.searchChanged,
    onStatusChanged: slot.cubit.setStatus,
  ),
  breadcrumb: (context) => AppBreadcrumb(
    items: [
      AppBreadcrumbItem(
        label: NavKeys.catalog,
        onTap: () => context.go(CatalogRoutes.hub.path),
      ),
      const AppBreadcrumbItem(label: ProductTypesKeys.title),
    ],
  ),
  viewModes: const [AppViewMode.table, AppViewMode.cards, AppViewMode.grid],
  capabilities: const CrudCapabilities(
    duplicate: false,
    bulkSelection: false,
  ),
  providersWrapper: (child) => BlocProvider<ProductTypeStatsCubit>(
    create: (_) => sl<ProductTypeStatsCubit>()..load(),
    child: child,
  ),
  isMutationEffect: (effect) => effect is ProductTypesMutatedEffect,
  onMutated: (context) => context.read<ProductTypeStatsCubit>().refresh(),
  statsBuilder: (slot) => BlocBuilder<ProductTypeStatsCubit, ProductTypeStatsState>(
    builder: (context, stats) => ProductTypeStatsBar(
      stats.stats,
      selectedFilter: slot.state.query.status,
      loading: stats is ProductTypeStatsLoading ||
          stats is ProductTypeStatsInitial,
      onFilterSelected: slot.cubit.setStatus,
    ),
  ),
  flows: CrudFlowsConfig<ProductType, ProductTypesListCubit>(
    showEditor: (context, {item, duplicate = false}) =>
        showProductTypeEditor(context, productType: item),
    onSaved: (cubit, {required isNew}) => cubit.onProductTypeSaved(isNew: isNew),
    itemLabel: (item) => item.name,
    delete: (cubit, item) => cubit.delete(item),
    activate: (cubit, item) => cubit.activate(item.id),
    deactivate: (cubit, item) => cubit.deactivate(item.id),
    labels: _labels,
    isActive: (item) => item.isActive,
    canDelete: (item) => item.canDelete,
    hideDeleteWhenCannotDelete: true,
  ),
  dataSection: (data) => ProductTypesDataSection(data: data, labels: _labels),
);
