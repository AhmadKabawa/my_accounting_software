import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:accounting_software/app/core/access/permissions.dart';
import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/core/localization/keys/nav_keys.dart';
import 'package:accounting_software/app/core/localization/keys/common_keys.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_breadcrumb/app_breadcrumb.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_table/data_table.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_list_config.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_data_section.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_flows_config.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_bulk_config.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_view/app_view_mode.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_filter_bar/filter_bar.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand_list_query.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/cubit/brand_stats/brand_stats_cubit.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/cubit/brand_stats/brand_stats_state.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/cubit/brands_list/brands_list_cubit.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/cubit/brands_list/brands_list_effect.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/localization/brands_keys.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/widgets/brand_card.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/widgets/brand_grid_tile.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/widgets/brand_logo.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/widgets/brand_status_badge.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/widgets/brand_stats_bar.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/widgets/brands_filter_bar.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/dialogs/brand_editor_dialog.dart';
import 'package:accounting_software/app/features/catalog/presentation/routing/catalog_routes.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_labels.dart';

const _crudLabels = CrudLabels(
  edit: BrandsKeys.edit,
  delete: BrandsKeys.delete,
  duplicate: BrandsKeys.duplicate,
  activate: BrandsKeys.activate,
  deactivate: BrandsKeys.deactivate,
  deleteConfirmationTitle: BrandsKeys.delete,
  deleteConfirmationMessage: BrandsKeys.confirmDelete,
  deactivateConfirmationTitle: BrandsKeys.deactivateTitle,
  deactivateConfirmationMessage: BrandsKeys.deactivateMessage,
);

CrudListConfig<Brand, BrandListQuery, BrandsListCubit, BrandsListEffect>
get brandsListConfig => CrudListConfig(
  screenId: 'catalog.brands',
  titleKey: BrandsKeys.title,
  manageAccess: Permissions.masterData.manage,
  searchHintKey: BrandsKeys.searchHint,
  addLabelKey: BrandsKeys.add,
  createCubit: () => sl<BrandsListCubit>(),
  rowId: (brand) => brand.id,
  itemLabel: (brand) => brand.name,
  sort: CrudSortConfig<BrandListQuery, BrandsListCubit>(
    options: BrandsFilterBar.sortOptions,
    current: (query) => [
      for (final item in query.sorts)
        FilterBarSort(item.field.name, item.ascending),
    ],
    tableKey: (query) => query.sortField.name,
    tableAscending: (query) => query.sortAscending,
    apply: (cubit, sorts) => cubit.setSorts(
      mapFilterBarSorts<BrandSortField, BrandSort>(
        sorts,
        parse: BrandSortField.tryParse,
        build: (field, ascending) => BrandSort(field, ascending),
      ),
    ),
    applyTable: (cubit, sort) => cubit.setSort(
      field: BrandSortField.tryParse(sort.key),
      ascending: sort.ascending,
    ),
  ),
  filterControls: (slot) => BrandsFilterBar.controls(
    slot.context,
    slot.state.query,
    onStatusChanged: slot.cubit.setStatus,
  ),
  activeFilters: (slot) => BrandsFilterBar.activeFilters(
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
      const AppBreadcrumbItem(label: BrandsKeys.title),
    ],
  ),
  viewModes: const [AppViewMode.table, AppViewMode.cards, AppViewMode.grid],
  capabilities: const CrudCapabilities(duplicate: true, bulkSelection: true),
  providersWrapper: (child) => BlocProvider<BrandStatsCubit>(
    create: (_) => sl<BrandStatsCubit>()..load(),
    child: child,
  ),
  isMutationEffect: (effect) => effect is BrandsMutatedEffect,
  onMutated: (context) => context.read<BrandStatsCubit>().refresh(),
  statsBuilder: (slot) => BlocBuilder<BrandStatsCubit, BrandStatsState>(
    builder: (context, stats) => BrandStatsBar(
      stats.stats,
      selectedFilter: slot.state.query.status,
      loading: stats is BrandStatsLoading || stats is BrandStatsInitial,
      onFilterSelected: slot.cubit.setStatus,
    ),
  ),
  flows: CrudFlowsConfig<Brand, BrandsListCubit>(
    showEditor: (context, {item, duplicate = false}) =>
        showBrandEditor(context, brand: item, duplicate: duplicate),
    onSaved: (cubit, {required isNew}) => cubit.onBrandSaved(isNew: isNew),
    itemLabel: (brand) => brand.name,
    delete: (cubit, brand) => cubit.delete(brand),
    activate: (cubit, brand) => cubit.activate(brand.id),
    deactivate: (cubit, brand) => cubit.deactivate(brand.id),
    labels: _crudLabels,

    isActive: (brand) => brand.isActive,
    canDelete: (brand) => brand.canDelete,
  ),
  bulk: CrudBulkConfig<Brand, BrandsListCubit>(
    activateLabelKey: BrandsKeys.bulkActivate,
    deactivateLabelKey: BrandsKeys.bulkDeactivate,
    deleteLabelKey: BrandsKeys.bulkDelete,
    deactivateTitleKey: BrandsKeys.bulkDeactivateTitle,
    deactivateMessageKey: BrandsKeys.bulkDeactivateMessage,
    deleteTitleKey: BrandsKeys.bulkDeleteTitle,
    deleteMessageKey: BrandsKeys.bulkDeleteMessage,
    activate: (cubit, items) => cubit.bulkActivate(items),
    deactivate: (cubit, items) => cubit.bulkDeactivate(items),
    delete: (cubit, items) => cubit.bulkDelete(items),
  ),
  dataSection: (data) =>
      CrudDataSection<Brand, BrandListQuery, BrandsListCubit>(
        data: data,
        columns: [
          DataTableColumn(
            labelKey: BrandsKeys.brandName,
            sortKey: 'name',
            priority: DataTableColumnPriority.primary,
            flex: 3,
            cellBuilder: (_, brand) => BrandIdentity(brand),
          ),
          DataTableColumn(
            labelKey: BrandsKeys.description,
            priority: DataTableColumnPriority.secondary,
            flex: 2,
            cellBuilder: (context, brand) => AppText.raw(
              brand.description?.trim() ?? '',
              color: context.ui.theme.colors.onSurfaceVariant,
              maxLines: 2,
            ),
          ),
          DataTableColumn(
            labelKey: BrandsKeys.productCount,
            numeric: true,
            priority: DataTableColumnPriority.secondary,
            cellBuilder: (context, brand) => brand.productCount == null
                ? const AppText(CommonKeys.noValue)
                : AppText.raw(
                    brand.productCount.toString(),
                    color: context.ui.theme.colors.onSurface,
                  ),
          ),
          DataTableColumn(
            labelKey: BrandsKeys.updatedAt,
            sortKey: 'updated',
            priority: DataTableColumnPriority.secondary,
            cellBuilder: (context, brand) => brand.updatedAt == null
                ? const AppText(CommonKeys.noValue)
                : AppText.raw(
                    MaterialLocalizations.of(
                      context,
                    ).formatShortDate(brand.updatedAt!),
                    color: context.ui.theme.colors.onSurfaceVariant,
                  ),
          ),
        ],
        labels: _crudLabels,
        statusColumn: CrudStatusColumnConfig<Brand>(
          labelKey: BrandsKeys.status,
          sortKey: 'status',
          isActive: (brand) => brand.isActive,
          badgeBuilder: (_, brand) => BrandStatusBadge(brand),
        ),
        cardBuilder: (_, brand) => BrandCard(brand),
        gridBuilder: (_, brand) => BrandGridTile(brand),
        icon: AppIcons.brands,
        emptyTitleKey: BrandsKeys.empty,
        emptyDescriptionKey: BrandsKeys.emptyDescription,
        noResultsTitleKey: BrandsKeys.noResults,
        noResultsDescriptionKey: BrandsKeys.noResultsDescription,
        canDelete: (brand) => brand.canDelete,
      ),
);
