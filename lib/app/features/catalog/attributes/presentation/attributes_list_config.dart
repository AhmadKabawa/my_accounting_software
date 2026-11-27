import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:accounting_software/app/core/access/permissions.dart';
import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/core/localization/keys/nav_keys.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_breadcrumb/app_breadcrumb.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_card/app_card.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_table/data_table.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_view/app_view_mode.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_row_actions/app_row_actions.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_data_section.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_flows_config.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_labels.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_list_config.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/entity/catalog_attribute.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/entity/attribute_list_query.dart';
import 'package:accounting_software/app/features/catalog/attributes/presentation/cubit/attributes_list/attributes_list_cubit.dart';
import 'package:accounting_software/app/features/catalog/attributes/presentation/cubit/attributes_list/attributes_list_effect.dart';
import 'package:accounting_software/app/features/catalog/attributes/presentation/cubit/attribute_stats/attribute_stats_cubit.dart';
import 'package:accounting_software/app/features/catalog/attributes/presentation/cubit/attribute_stats/attribute_stats_state.dart';
import 'package:accounting_software/app/features/catalog/attributes/presentation/dialogs/attribute_editor_launcher.dart';
import 'package:accounting_software/app/features/catalog/attributes/presentation/widgets/attribute_delete_action.dart';
import 'package:accounting_software/app/features/catalog/attributes/presentation/localization/attributes_keys.dart';
import 'package:accounting_software/app/features/catalog/attributes/presentation/widgets/attributes_filter_bar.dart';
import 'package:accounting_software/app/features/catalog/attributes/presentation/sections/attribute_stats_section.dart';
import 'package:accounting_software/app/features/catalog/presentation/routing/catalog_routes.dart';

const _labels = CrudLabels(
  edit: AttributesKeys.edit,
  duplicate: AttributesKeys.duplicate,
  activate: AttributesKeys.activate,
  deactivate: AttributesKeys.deactivate,
  deactivateConfirmationTitle: AttributesKeys.deactivate,
  deactivateConfirmationMessage: AttributesKeys.confirmDeactivate,
);

AppKey _typeLabel(BuildContext context, AttributeDataType type) =>
    AttributesFilterBar.typeLabel(type);

CrudListConfig<
  CatalogAttribute,
  AttributeListQuery,
  AttributesListCubit,
  AttributesListEffect
>
get attributesListConfig => CrudListConfig(
  screenId: 'catalog.attributes',
  titleKey: AttributesKeys.title,
  manageAccess: Permissions.masterData.manage,
  searchHintKey: AttributesKeys.search,
  addLabelKey: AttributesKeys.add,
  createCubit: () => sl<AttributesListCubit>(),
  rowId: (item) => item.id,
  itemLabel: (item) => item.name,
  sort: CrudSortConfig<AttributeListQuery, AttributesListCubit>(
    current: (_) => const [],
    tableKey: (_) => null,
    tableAscending: (_) => true,
    apply: (_, _) {},
    applyTable: (_, _) {},
  ),
  filterControls: (slot) => AttributesFilterBar.controls(
    slot.context,
    slot.state.query,
    onStatusChanged: slot.cubit.setStatus,
    onTypeChanged: slot.cubit.setDataType,
    onFilterableChanged: slot.cubit.setFilterable,
  ),
  activeFilters: (slot) => AttributesFilterBar.activeFilters(
    slot.context,
    slot.state.query,
    onSearchChanged: slot.cubit.searchChanged,
    onStatusChanged: slot.cubit.setStatus,
    onTypeChanged: slot.cubit.setDataType,
    onFilterableChanged: slot.cubit.setFilterable,
  ),
  breadcrumb: (context) => AppBreadcrumb(
    items: [
      AppBreadcrumbItem(
        label: NavKeys.catalog,
        onTap: () => context.go(CatalogRoutes.hub.path),
      ),
      const AppBreadcrumbItem(label: AttributesKeys.title),
    ],
  ),
  viewModes: const [AppViewMode.table, AppViewMode.cards],
  capabilities: const CrudCapabilities(duplicate: true, bulkSelection: false),
  providersWrapper: (child) => BlocProvider<AttributeStatsCubit>(
    create: (_) => sl<AttributeStatsCubit>()..load(),
    child: child,
  ),
  isMutationEffect: (effect) => effect is AttributesMutatedEffect,
  onMutated: (context) => context.read<AttributeStatsCubit>().refresh(),
  statsBuilder: (slot) => BlocBuilder<AttributeStatsCubit, AttributeStatsState>(
    builder: (context, stats) => AttributeStatsSection(
      stats: stats.stats,
      selectedFilter: slot.state.query.status,
      onStatusSelected: slot.cubit.setStatus,
      loading:
          stats.status == AttributeStatsStatus.initial ||
          stats.status == AttributeStatsStatus.loading,
      failure: stats.failure?.messageKey,
      onRetry: context.read<AttributeStatsCubit>().refresh,
    ),
  ),
  flows: CrudFlowsConfig<CatalogAttribute, AttributesListCubit>(
    showEditor: (context, {item, duplicate = false}) =>
        showAttributeEditor(context, attribute: item, duplicate: duplicate),
    onSaved: (cubit, {required isNew}) => cubit.onSaved(isNew: isNew),
    itemLabel: (item) => item.name,
    activate: (cubit, item) => cubit.activate(item.id),
    deactivate: (cubit, item) => cubit.deactivate(item.id),
    isActive: (item) => item.isActive,
    labels: _labels,
  ),
  dataSection: (data) =>
      CrudDataSection<
        CatalogAttribute,
        AttributeListQuery,
        AttributesListCubit
      >(
        data: data,
        columns: [
          DataTableColumn(
            labelKey: AttributesKeys.attributeName,
            sortKey: 'name',
            priority: DataTableColumnPriority.primary,
            flex: 3,
            cellBuilder: (_, item) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [AppText.raw(item.name), AppText.raw(item.code)],
            ),
          ),
          DataTableColumn(
            labelKey: AttributesKeys.dataType,
            priority: DataTableColumnPriority.primary,
            cellBuilder: (context, item) =>
                AppText(_typeLabel(context, item.dataType)),
          ),
          DataTableColumn(
            labelKey: AttributesKeys.unit,
            priority: DataTableColumnPriority.secondary,
            cellBuilder: (context, item) => AppText.raw(
              item.dataType == AttributeDataType.option
                  ? item.optionSetName ??
                        AttributesKeys.unknown.tr(context: context)
                  : item.unitName ??
                        AttributesKeys.unknown.tr(context: context),
            ),
          ),
          DataTableColumn(
            labelKey: AttributesKeys.filterable,
            priority: DataTableColumnPriority.secondary,
            cellBuilder: (_, item) => AppText(
              item.isFilterable
                  ? AttributesKeys.filterableOn
                  : AttributesKeys.notFilterable,
            ),
          ),
          DataTableColumn(
            labelKey: AttributesKeys.linkedProductTypes,
            numeric: true,
            priority: DataTableColumnPriority.secondary,
            cellBuilder: (context, item) => AppText.raw(
              item.linkedProductTypesCount?.toString() ??
                  AttributesKeys.unknown.tr(context: context),
            ),
          ),
        ],
        labels: _labels,
        statusColumn: CrudStatusColumnConfig<CatalogAttribute>(
          labelKey: AttributesKeys.status,
          isActive: (item) => item.isActive,
          badgeBuilder: (_, item) => AppText(
            item.isActive ? AttributesKeys.active : AttributesKeys.inactive,
          ),
        ),
        extraRowActions: (context, item) => item.canDelete
            ? [
                AppRowAction(
                  icon: AppIcons.delete,
                  labelKey: AttributesKeys.delete,
                  destructive: true,
                  onPressed: () => confirmDeleteAttribute(context, item),
                ),
              ]
            : const [],
        cardBuilder: (context, item) => AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText.raw(item.name),
              AppText.raw(item.code),
              AppText(_typeLabel(context, item.dataType)),
              AppText(
                item.isActive ? AttributesKeys.active : AttributesKeys.inactive,
              ),
            ],
          ),
        ),
        gridBuilder: (context, item) => AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [AppText.raw(item.name), AppText.raw(item.code)],
          ),
        ),
        icon: AppIcons.catalog,
        emptyTitleKey: AttributesKeys.empty,
        emptyDescriptionKey: AttributesKeys.emptyDescription,
        noResultsTitleKey: AttributesKeys.noResults,
        noResultsDescriptionKey: AttributesKeys.noResultsDescription,
      ),
);
