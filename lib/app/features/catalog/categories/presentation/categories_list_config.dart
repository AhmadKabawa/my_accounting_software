import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:accounting_software/app/core/access/permissions.dart';
import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/core/localization/keys/nav_keys.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_breadcrumb/app_breadcrumb.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_table/data_table.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_filter_bar/filter_bar.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_row_actions/app_row_actions.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_bulk_config.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_data_section.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_flows_config.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_labels.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_list_config.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_view/app_view_mode.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/entity/category_list_query.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/entity/category_node.dart';
import 'package:accounting_software/app/features/catalog/categories/presentation/cubit/categories_list/categories_list_cubit.dart';
import 'package:accounting_software/app/features/catalog/categories/presentation/cubit/categories_list/categories_list_effect.dart';
import 'package:accounting_software/app/features/catalog/categories/presentation/dialogs/category_editor_launcher.dart';
import 'package:accounting_software/app/features/catalog/categories/presentation/localization/categories_keys.dart';
import 'package:accounting_software/app/features/catalog/categories/presentation/widgets/categories_filter_bar.dart';
import 'package:accounting_software/app/features/catalog/categories/presentation/widgets/categories_flat_results_note.dart';
import 'package:accounting_software/app/features/catalog/categories/presentation/widgets/categories_tree_toolbar.dart';
import 'package:accounting_software/app/features/catalog/categories/presentation/widgets/category_card.dart';
import 'package:accounting_software/app/features/catalog/categories/presentation/widgets/category_stats_bar.dart';
import 'package:accounting_software/app/features/catalog/categories/presentation/widgets/category_identity.dart';
import 'package:accounting_software/app/features/catalog/categories/presentation/widgets/category_status_badge.dart';
import 'package:accounting_software/app/features/catalog/presentation/routing/catalog_routes.dart';

const _crudLabels = CrudLabels(
  edit: CategoriesKeys.edit,
  delete: CategoriesKeys.delete,
  activate: CategoriesKeys.activate,
  deactivate: CategoriesKeys.deactivate,
  deleteConfirmationTitle: CategoriesKeys.delete,
  deleteConfirmationMessage: CategoriesKeys.deleteMessage,
  deactivateConfirmationTitle: CategoriesKeys.deactivateTitle,
  deactivateConfirmationMessage: CategoriesKeys.deactivateMessage,
);

CrudListConfig<
  CategoryNode,
  CategoryListQuery,
  CategoriesListCubit,
  CategoriesListEffect
>
get categoriesListConfig => CrudListConfig(
  screenId: 'catalog.categories',
  titleKey: CategoriesKeys.title,
  manageAccess: Permissions.masterData.manage,
  searchHintKey: CategoriesKeys.searchHint,
  addLabelKey: CategoriesKeys.add,
  createCubit: () => sl<CategoriesListCubit>(),
  rowId: (node) => node.id,
  itemLabel: (node) => node.category.name,
  sort: CrudSortConfig<CategoryListQuery, CategoriesListCubit>(
    optionsForQuery: (query) => query.hasActiveFilters
        ? CategoriesFilterBar.sortOptions
        : const [],
    current: (query) => query.hasActiveFilters
        ? [FilterBarSort(query.sortField.name, query.sortAscending)]
        : const [],
    tableKey: (query) => query.hasActiveFilters ? query.sortField.name : null,
    tableAscending: (query) => query.sortAscending,
    apply: (cubit, sorts) {
      if (sorts.isEmpty) return;
      final field = CategorySortField.tryParse(sorts.first.key);
      if (field != null) cubit.setSort(field, sorts.first.ascending);
    },
    applyTable: (cubit, sort) {
      final field = CategorySortField.tryParse(sort.key);
      if (field != null) cubit.setSort(field, sort.ascending);
    },
  ),
  filterControls: (slot) => CategoriesFilterBar.controls(
    slot.context,
    slot.state.query,
    onStatusChanged: slot.cubit.setStatus,
    onLevelChanged: slot.cubit.setLevel,
    onUsageChanged: slot.cubit.setUsage,
  ),
  activeFilters: (slot) => CategoriesFilterBar.activeFilters(
    slot.context,
    slot.state.query,
    onSearchChanged: slot.cubit.searchChanged,
    onStatusChanged: slot.cubit.setStatus,
    onLevelChanged: slot.cubit.setLevel,
    onUsageChanged: slot.cubit.setUsage,
  ),
  breadcrumb: (context) => AppBreadcrumb(
    items: [
      AppBreadcrumbItem(
        label: NavKeys.catalog,
        onTap: () => context.go(CatalogRoutes.hub.path),
      ),
      const AppBreadcrumbItem(label: CategoriesKeys.title),
    ],
  ),
  viewModes: const [AppViewMode.table, AppViewMode.cards],
  capabilities: const CrudCapabilities(duplicate: true, bulkSelection: true),
  statsBuilder: (slot) => CategoryStatsBar(
    tree: slot.cubit.tree,
    query: slot.state.query,
    onSelected: (filter) {
      switch (filter) {
        case CategoryStatsFilter.all:
          slot.cubit.clearFilters();
        case CategoryStatsFilter.active:
          slot.cubit.setStatus(CategoryStatusFilter.active);
        case CategoryStatsFilter.inactive:
          slot.cubit.setStatus(CategoryStatusFilter.inactive);
        case CategoryStatsFilter.roots:
          slot.cubit.setLevel(CategoryLevelFilter.roots);
        case CategoryStatsFilter.leaves:
          slot.cubit.setLevel(CategoryLevelFilter.leaves);
        case CategoryStatsFilter.withoutProducts:
          slot.cubit.setUsage(CategoryUsageFilter.withoutProducts);
      }
    },
  ),
  flows: CrudFlowsConfig<CategoryNode, CategoriesListCubit>(
    showEditor: (context, {item, duplicate = false}) => showCategoryEditor(
      context,
      category: item?.category,
      tree: context.read<CategoriesListCubit>().tree,
    ),
    onSaved: (cubit, {required isNew}) => cubit.onCategorySaved(isNew: isNew),
    itemLabel: (node) => node.category.name,
    delete: (cubit, node) => cubit.delete(node),
    activate: (cubit, node) => cubit.activate(node.id),
    deactivate: (cubit, node) => cubit.deactivate(node.id),
    isActive: (node) => node.category.isActive,
    canDelete: (node) => node.canDelete,
    deactivateMessage: (node) => node.activeChildCount == 0
        ? null
        : (
            key: CategoriesKeys.deactivateWithChildrenMessage,
            args: {'count': node.activeChildCount.toString()},
          ),
    labels: _crudLabels,
  ),
  bulk: CrudBulkConfig<CategoryNode, CategoriesListCubit>(
    activateLabelKey: CategoriesKeys.bulkActivate,
    deactivateLabelKey: CategoriesKeys.bulkDeactivate,
    deleteLabelKey: CategoriesKeys.bulkDelete,
    deactivateTitleKey: CategoriesKeys.bulkDeactivateTitle,
    deactivateMessageKey: CategoriesKeys.bulkDeactivateMessage,
    deleteTitleKey: CategoriesKeys.bulkDeleteTitle,
    deleteMessageKey: CategoriesKeys.bulkDeleteMessage,
    activate: (cubit, items) => cubit.bulkActivate(items),
    deactivate: (cubit, items) => cubit.bulkDeactivate(items),
    delete: (cubit, items) => cubit.bulkDelete(items),
  ),
  dataSection: (data) {
    final section =
        CrudDataSection<CategoryNode, CategoryListQuery, CategoriesListCubit>(
          data: data,
          columns: [
            DataTableColumn<CategoryNode>(
              labelKey: CategoriesKeys.categoryName,
              priority: DataTableColumnPriority.primary,
              flex: 3,
              cellBuilder: (_, node) => CategoryIdentity(
                node: node,
                onToggle: node.hasChildren
                    ? () => data.cubit.toggleExpanded(node.id)
                    : null,
                showPathForDeep: true,
              ),
            ),
            DataTableColumn<CategoryNode>(
              labelKey: CategoriesKeys.description,
              priority: DataTableColumnPriority.secondary,
              flex: 2,
              cellBuilder: (context, node) => AppText.raw(
                node.category.description?.trim() ?? '',
                color: context.ui.theme.colors.onSurfaceVariant,
                maxLines: 2,
              ),
            ),
          ],
          labels: _crudLabels,
          statusColumn: CrudStatusColumnConfig<CategoryNode>(
            labelKey: CategoriesKeys.status,
            isActive: (node) => node.category.isActive,
            badgeBuilder: (_, node) => CategoryStatusBadge(node.category),
          ),
          cardBuilder: (_, node) => CategoryCard(
            node: node,
            onToggle: node.hasChildren
                ? () => data.cubit.toggleExpanded(node.id)
                : null,
          ),
          gridBuilder: (_, node) => CategoryCard(node: node),
          icon: AppIcons.catalog,
          emptyTitleKey: CategoriesKeys.empty,
          emptyDescriptionKey: CategoriesKeys.emptyDescription,
          noResultsTitleKey: CategoriesKeys.noResults,
          noResultsDescriptionKey: CategoriesKeys.noResultsDescription,
          extraRowActions: (context, node) {
            final flows = data.flows;
            if (flows == null) return const [];
            return [
              AppRowAction(
                icon: AppIcons.add,
                labelKey: CategoriesKeys.addChild,
                onPressed: () async {
                  final saved = await showCategoryEditor(
                    context,
                    tree: data.cubit.tree,
                    initialParentId: node.id,
                  );
                  if (saved == true && context.mounted) {
                    await flows.onSaved(data.cubit, isNew: true);
                  }
                },
              ),
            ];
          },
        );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CategoriesTreeToolbar(
          enabled: data.cubit.tree != null,
          onExpandAll: data.cubit.expandAll,
          onCollapseAll: data.cubit.collapseAll,
        ),
        if (data.query.hasActiveFilters) const CategoriesFlatResultsNote(),
        section,
      ],
    );
  },
);
