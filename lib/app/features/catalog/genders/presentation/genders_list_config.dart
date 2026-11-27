import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:accounting_software/app/core/access/permissions.dart';
import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/core/localization/keys/nav_keys.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_breadcrumb/app_breadcrumb.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_table/data_table.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_view/app_view_mode.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_filter_bar/filter_bar.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_bulk_config.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_data_section.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_flows_config.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_labels.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_list_config.dart';
import 'package:accounting_software/app/features/catalog/genders/domain/entity/gender.dart';
import 'package:accounting_software/app/features/catalog/genders/domain/entity/gender_list_query.dart';
import 'package:accounting_software/app/features/catalog/genders/presentation/cubit/gender_stats/gender_stats_cubit.dart';
import 'package:accounting_software/app/features/catalog/genders/presentation/cubit/gender_stats/gender_stats_state.dart';
import 'package:accounting_software/app/features/catalog/genders/presentation/cubit/genders_list/genders_list_cubit.dart';
import 'package:accounting_software/app/features/catalog/genders/presentation/cubit/genders_list/genders_list_effect.dart';
import 'package:accounting_software/app/features/catalog/genders/presentation/dialogs/gender_editor_launcher.dart';
import 'package:accounting_software/app/features/catalog/genders/presentation/localization/genders_keys.dart';
import 'package:accounting_software/app/features/catalog/genders/presentation/widgets/gender_status_badge.dart';
import 'package:accounting_software/app/features/catalog/genders/presentation/widgets/gender_stats_bar.dart';
import 'package:accounting_software/app/features/catalog/genders/presentation/widgets/genders_filter_bar.dart';
import 'package:accounting_software/app/features/catalog/presentation/routing/catalog_routes.dart';

const _labels = CrudLabels(
  edit: GendersKeys.edit,
  delete: GendersKeys.delete,
  activate: GendersKeys.activate,
  deactivate: GendersKeys.deactivate,
  deleteConfirmationTitle: GendersKeys.deleteTitle,
  deleteConfirmationMessage: GendersKeys.deleteMessage,
  deactivateConfirmationTitle: GendersKeys.deactivateTitle,
  deactivateConfirmationMessage: GendersKeys.deactivateMessage,
);

CrudListConfig<Gender, GenderListQuery, GendersListCubit, GendersListEffect>
get gendersListConfig => CrudListConfig(
  screenId: 'catalog.genders',
  titleKey: GendersKeys.title,
  manageAccess: Permissions.masterData.manage,
  searchHintKey: GendersKeys.searchHint,
  addLabelKey: GendersKeys.add,
  createCubit: () => sl<GendersListCubit>(),
  rowId: (gender) => gender.id,
  itemLabel: (gender) => gender.name,
  sort: CrudSortConfig<GenderListQuery, GendersListCubit>(
    options: GendersFilterBar.sortOptions,
    current: (query) => [for (final sort in query.sorts) FilterBarSort(sort.field.name, sort.ascending)],
    tableKey: (query) => query.sortField.name,
    tableAscending: (query) => query.sortAscending,
    apply: (cubit, sorts) => cubit.setSorts(
      mapFilterBarSorts<GenderSortField, GenderSort>(
        sorts,
        parse: GenderSortField.tryParse,
        build: (field, ascending) => GenderSort(field, ascending),
      ),
    ),
    applyTable: (cubit, sort) {
      final field = GenderSortField.tryParse(sort.key);
      if (field != null) cubit.setSorts([GenderSort(field, sort.ascending)]);
    },
  ),
  filterControls: (slot) => GendersFilterBar.controls(slot.context, slot.state.query, onStatusChanged: slot.cubit.setStatus),
  activeFilters: (slot) => GendersFilterBar.activeFilters(
    slot.context, slot.state.query,
    onSearchChanged: slot.cubit.searchChanged,
    onStatusChanged: slot.cubit.setStatus,
  ),
  breadcrumb: (context) => AppBreadcrumb(items: [
    AppBreadcrumbItem(label: NavKeys.catalog, onTap: () => context.go(CatalogRoutes.hub.path)),
    const AppBreadcrumbItem(label: GendersKeys.title),
  ]),
  viewModes: const [AppViewMode.table, AppViewMode.cards],
  capabilities: const CrudCapabilities(showCount: true, bulkSelection: true),
  providersWrapper: (child) => BlocProvider<GenderStatsCubit>(
    create: (_) => sl<GenderStatsCubit>()..load(),
    child: child,
  ),
  isMutationEffect: (effect) => effect is GendersMutatedEffect,
  onMutated: (context) => context.read<GenderStatsCubit>().refresh(),
  statsBuilder: (slot) => BlocBuilder<GenderStatsCubit, GenderStatsState>(
    builder: (context, state) => GenderStatsBar(
      state.stats,
      selected: slot.state.query.status,
      loading: state.status == GenderStatsStatus.initial || state.status == GenderStatsStatus.loading,
      onSelected: slot.cubit.setStatus,
    ),
  ),
  flows: CrudFlowsConfig<Gender, GendersListCubit>(
    showEditor: (context, {item, duplicate = false}) => showGenderEditor(context, gender: item),
    onSaved: (cubit, {required isNew}) => cubit.onGenderSaved(isNew: isNew),
    itemLabel: (gender) => gender.name,
    delete: (cubit, gender) => cubit.delete(gender),
    activate: (cubit, gender) => cubit.activate(gender.id),
    deactivate: (cubit, gender) => cubit.deactivate(gender.id),
    labels: _labels,
    isActive: (gender) => gender.isActive,
    canDelete: (gender) => gender.canDelete,
  ),
  bulk: CrudBulkConfig<Gender, GendersListCubit>(
    activateLabelKey: GendersKeys.bulkActivate,
    deactivateLabelKey: GendersKeys.bulkDeactivate,
    deleteLabelKey: GendersKeys.bulkDelete,
    deactivateTitleKey: GendersKeys.bulkDeactivateTitle,
    deactivateMessageKey: GendersKeys.bulkDeactivateMessage,
    deleteTitleKey: GendersKeys.bulkDeleteTitle,
    deleteMessageKey: GendersKeys.bulkDeleteMessage,
    activate: (cubit, items) => cubit.bulkActivate(items),
    deactivate: (cubit, items) => cubit.bulkDeactivate(items),
    delete: (cubit, items) => cubit.bulkDelete(items),
  ),
  dataSection: (data) => CrudDataSection<Gender, GenderListQuery, GendersListCubit>(
    data: data,
    columns: [
      DataTableColumn(
        labelKey: GendersKeys.name,
        sortKey: 'name',
        priority: DataTableColumnPriority.primary,
        flex: 3,
        cellBuilder: (_, gender) => AppText.raw(gender.name),
      ),
      DataTableColumn(
        labelKey: GendersKeys.code,
        sortKey: 'code',
        priority: DataTableColumnPriority.secondary,
        flex: 2,
        cellBuilder: (_, gender) => Directionality(
          textDirection: TextDirection.ltr,
          child: AppText.raw(gender.code),
        ),
      ),
      DataTableColumn(
        labelKey: GendersKeys.sortOrder,
        sortKey: 'order',
        numeric: true,
        priority: DataTableColumnPriority.secondary,
        cellBuilder: (_, gender) => AppText.raw(gender.sortOrder.toString()),
      ),
    ],
    labels: _labels,
    statusColumn: CrudStatusColumnConfig<Gender>(
      labelKey: GendersKeys.status,
      isActive: (gender) => gender.isActive,
      badgeBuilder: (_, gender) => GenderStatusBadge(gender),
    ),
    cardBuilder: (_, gender) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText.raw(gender.name, type: AppTextType.titleMedium),
        AppText.raw(gender.code),
        AppText.raw(gender.sortOrder.toString()),
        GenderStatusBadge(gender),
      ],
    ),
    icon: AppIcons.catalog,
    emptyTitleKey: GendersKeys.empty,
    emptyDescriptionKey: GendersKeys.noResults,
    noResultsTitleKey: GendersKeys.noResults,
    noResultsDescriptionKey: GendersKeys.noResults,
  ),
);
