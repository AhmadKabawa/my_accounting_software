import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:accounting_software/app/core/access/permissions.dart';
import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/core/localization/keys/nav_keys.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_breadcrumb/app_breadcrumb.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_table/data_table.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_view/app_view_mode.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_bulk_config.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_filter_bar/filter_bar.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_data_section.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_list_config.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_flows_config.dart';
import 'package:accounting_software/app/features/catalog/tags/domain/entity/catalog_tag.dart';
import 'package:accounting_software/app/features/catalog/tags/domain/entity/tag_list_query.dart';
import 'package:accounting_software/app/features/catalog/tags/presentation/cubit/tag_stats/tag_stats_cubit.dart';
import 'package:accounting_software/app/features/catalog/tags/presentation/cubit/tag_stats/tag_stats_state.dart';
import 'package:accounting_software/app/features/catalog/tags/presentation/cubit/tags_list/tags_list_cubit.dart';
import 'package:accounting_software/app/features/catalog/tags/presentation/cubit/tags_list/tags_list_effect.dart';
import 'package:accounting_software/app/features/catalog/tags/presentation/dialogs/tag_editor_launcher.dart';
import 'package:accounting_software/app/features/catalog/tags/presentation/localization/tags_keys.dart';
import 'package:accounting_software/app/features/catalog/tags/presentation/sections/tag_stats_section.dart';
import 'package:accounting_software/app/features/catalog/tags/presentation/widgets/tag_card.dart';
import 'package:accounting_software/app/features/catalog/tags/presentation/widgets/tag_grid_tile.dart';
import 'package:accounting_software/app/features/catalog/tags/presentation/widgets/tag_identity.dart';
import 'package:accounting_software/app/features/catalog/tags/presentation/widgets/tag_status_badge.dart';
import 'package:accounting_software/app/features/catalog/tags/presentation/widgets/tags_filter_bar.dart';
import 'package:accounting_software/app/features/catalog/presentation/routing/catalog_routes.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_labels.dart';

const _crudLabels = CrudLabels(
  edit: TagsKeys.edit,
  delete: TagsKeys.delete,
  duplicate: TagsKeys.duplicate,
  activate: TagsKeys.activate,
  deactivate: TagsKeys.deactivate,
  deleteConfirmationTitle: TagsKeys.deleteTitle,
  deleteConfirmationMessage: TagsKeys.deleteMessage,
  deactivateConfirmationTitle: TagsKeys.deactivateTitle,
  deactivateConfirmationMessage: TagsKeys.deactivateMessage,
);

CrudListConfig<CatalogTag, TagListQuery, TagsListCubit, TagsListEffect>
get tagsListConfig => CrudListConfig(
  screenId: 'catalog.tags',
  titleKey: TagsKeys.title,
  manageAccess: Permissions.masterData.manage,
  searchHintKey: TagsKeys.searchHint,
  addLabelKey: TagsKeys.add,
  createCubit: () => sl<TagsListCubit>(),
  rowId: (tag) => tag.id,
  itemLabel: (tag) => tag.name,
  sort: CrudSortConfig<TagListQuery, TagsListCubit>(
    options: TagsFilterBar.sortOptions,
    current: (query) => [
      for (final item in query.sorts)
        FilterBarSort(item.field.name, item.ascending),
    ],
    tableKey: (query) => query.sortField.name,
    tableAscending: (query) => query.sortAscending,
    apply: (cubit, sorts) => cubit.setSorts(
      mapFilterBarSorts<TagSortField, TagSort>(
        sorts,
        parse: TagSortField.tryParse,
        build: (field, ascending) => TagSort(field, ascending),
      ),
    ),
    applyTable: (cubit, sort) {
      final field = TagSortField.tryParse(sort.key);
      if (field != null) {
        cubit.setSorts([TagSort(field, sort.ascending)]);
      }
    },
  ),
  filterControls: (slot) => TagsFilterBar.controls(
    slot.context,
    slot.state.query,
    onStatusChanged: slot.cubit.setStatus,
  ),
  activeFilters: (slot) => TagsFilterBar.activeFilters(
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
      const AppBreadcrumbItem(label: TagsKeys.title),
    ],
  ),
  viewModes: const [AppViewMode.table, AppViewMode.cards, AppViewMode.grid],
  capabilities: const CrudCapabilities(
    showCount: true,
    duplicate: true,
    bulkSelection: true,
  ),
  providersWrapper: (child) => BlocProvider<TagStatsCubit>(
    create: (_) => sl<TagStatsCubit>()..load(),
    child: child,
  ),
  isMutationEffect: (effect) => effect is TagsMutatedEffect,
  onMutated: (context) => context.read<TagStatsCubit>().refresh(),
  statsBuilder: (slot) => BlocBuilder<TagStatsCubit, TagStatsState>(
    builder: (context, statsState) => TagStatsSection(
      stats: statsState.stats,
      selectedFilter: slot.state.query.status,
      onStatusSelected: slot.cubit.setStatus,
      loading:
          statsState.status == TagStatsStatus.loading ||
          statsState.status == TagStatsStatus.initial,
      failure: statsState.failure?.messageKey,
      onRetry: context.read<TagStatsCubit>().refresh,
    ),
  ),
  flows: CrudFlowsConfig<CatalogTag, TagsListCubit>(
    showEditor: (context, {item, duplicate = false}) =>
        showTagEditor(context, tag: item, duplicate: duplicate),
    onSaved: (cubit, {required isNew}) => cubit.onTagSaved(isNew: isNew),
    itemLabel: (tag) => tag.name,
    delete: (cubit, tag) => cubit.delete(tag),
    activate: (cubit, tag) => cubit.activate(tag.id),
    deactivate: (cubit, tag) => cubit.deactivate(tag.id),
    labels: _crudLabels,
    messageArgs: (tag) => {'name': tag.name},

    isActive: (tag) => tag.isActive,
  ),
  bulk: CrudBulkConfig<CatalogTag, TagsListCubit>(
    activateLabelKey: TagsKeys.bulkActivate,
    deactivateLabelKey: TagsKeys.bulkDeactivate,
    deleteLabelKey: TagsKeys.bulkDelete,
    deactivateTitleKey: TagsKeys.bulkDeactivateTitle,
    deactivateMessageKey: TagsKeys.bulkDeactivateMessage,
    deleteTitleKey: TagsKeys.bulkDeleteTitle,
    deleteMessageKey: TagsKeys.bulkDeleteMessage,
    activate: (cubit, items) => cubit.bulkActivate(items),
    deactivate: (cubit, items) => cubit.bulkDeactivate(items),
    delete: (cubit, items) => cubit.bulkDelete(items),
  ),
  dataSection: (data) =>
      CrudDataSection<CatalogTag, TagListQuery, TagsListCubit>(
        data: data,
        columns: [
          DataTableColumn(
            labelKey: TagsKeys.tagName,
            sortKey: 'name',
            priority: DataTableColumnPriority.primary,
            flex: 3,
            cellBuilder: (_, tag) => TagIdentity(tag),
          ),
          DataTableColumn(
            labelKey: TagsKeys.slug,
            sortKey: 'slug',
            priority: DataTableColumnPriority.secondary,
            flex: 2,
            cellBuilder: (_, tag) => Directionality(
              textDirection: TextDirection.ltr,
              child: AppText.raw(tag.slug),
            ),
          ),
        ],
        labels: _crudLabels,
        statusColumn: CrudStatusColumnConfig<CatalogTag>(
          labelKey: TagsKeys.status,
          isActive: (tag) => tag.isActive,
          badgeBuilder: (_, tag) => TagStatusBadge(tag),
        ),
        cardBuilder: (_, tag) => TagCard(tag),
        gridBuilder: (_, tag) => TagGridTile(tag),
        icon: AppIcons.tags,
        emptyTitleKey: TagsKeys.empty,
        emptyDescriptionKey: TagsKeys.emptyDescription,
        noResultsTitleKey: TagsKeys.noResults,
        noResultsDescriptionKey: TagsKeys.noResultsDescription,
      ),
);
