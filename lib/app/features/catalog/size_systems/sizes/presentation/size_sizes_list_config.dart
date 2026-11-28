import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/access/permissions.dart';
import 'package:accounting_software/app/core/localization/keys/common_keys.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_table/data_table.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_view/app_view_mode.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_filter_bar/filter_bar.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_data_section.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_flows_config.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_labels.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_list_config.dart';
import 'package:accounting_software/app/features/catalog/size_systems/presentation/localization/size_systems_keys.dart';
import 'package:accounting_software/app/features/catalog/size_systems/presentation/routing/size_systems_routes.dart';
import 'package:accounting_software/app/features/catalog/size_systems/presentation/widgets/size_breadcrumbs.dart';
import 'package:accounting_software/app/features/catalog/size_systems/presentation/widgets/size_filter_bar.dart';
import 'package:accounting_software/app/features/catalog/size_systems/presentation/widgets/size_list_cells.dart';
import 'package:accounting_software/app/features/catalog/size_systems/presentation/widgets/size_status_badge.dart';
import 'package:accounting_software/app/features/catalog/size_systems/sizes/domain/entity/catalog_size.dart';
import 'package:accounting_software/app/features/catalog/size_systems/sizes/domain/entity/catalog_size_list_query.dart';
import 'package:accounting_software/app/features/catalog/size_systems/sizes/presentation/cubit/sizes_list/sizes_list_cubit.dart';
import 'package:accounting_software/app/features/catalog/size_systems/sizes/presentation/cubit/sizes_list/sizes_list_effect.dart';
import 'package:accounting_software/app/features/catalog/size_systems/sizes/presentation/dialogs/size_editor_launcher.dart';
import 'package:accounting_software/app/features/catalog/size_systems/sizes/presentation/dialogs/size_range_launcher.dart';

const _labels = CrudLabels(
  edit: SizeSystemsKeys.edit,
  delete: SizeSystemsKeys.delete,
  activate: SizeSystemsKeys.activate,
  deactivate: SizeSystemsKeys.deactivate,
  deleteConfirmationTitle: SizeSystemsKeys.deleteTitle,
  deleteConfirmationMessage: SizeSystemsKeys.deleteMessage,
  deactivateConfirmationTitle: SizeSystemsKeys.deactivateTitle,
  deactivateConfirmationMessage: SizeSystemsKeys.deactivateMessage,
);

/// The sizes of one group, loaded only when the group is opened (D-SZ-2).
/// Ids come from the route path; [labels] only decorates the header.
CrudListConfig<
  CatalogSize,
  CatalogSizeListQuery,
  SizesListCubit,
  SizesListEffect
>
sizesListConfig(int systemId, int groupId, {SizeRouteContext? labels}) =>
    CrudListConfig(
      screenId: 'catalog.sizeGroupSizes',
      titleKey: SizeSystemsKeys.sizesTitle,
      manageAccess: Permissions.masterData.manage,
      searchHintKey: SizeSystemsKeys.searchHint,
      addLabelKey: SizeSystemsKeys.addSize,
      createCubit: () => sl<SizesListCubit>(param1: groupId),
      rowId: (size) => size.id,
      itemLabel: (size) => size.name,
      sort: CrudSortConfig<CatalogSizeListQuery, SizesListCubit>(
        options: SizeFilterBar.sizeSortOptions,
        maxSorts: 1,
        current: (query) => [
          FilterBarSort(query.sortField.name, query.sortAscending),
        ],
        tableKey: (query) => query.sortField.name,
        tableAscending: (query) => query.sortAscending,
        apply: (cubit, sorts) {
          if (sorts.isEmpty) return;
          final field = CatalogSizeSortField.tryParse(sorts.first.key);
          if (field != null) cubit.setSort(field, sorts.first.ascending);
        },
        applyTable: (cubit, sort) {
          final field = CatalogSizeSortField.tryParse(sort.key);
          if (field != null) cubit.setSort(field, sort.ascending);
        },
      ),
      filterControls: (slot) => [
        SizeFilterBar.statusControl(
          slot.context,
          slot.state.query.status,
          slot.cubit.setStatus,
        ),
      ],
      activeFilters: (slot) => SizeFilterBar.activeFilters(
        slot.context,
        search: slot.state.query.search,
        status: slot.state.query.status,
        onSearchChanged: slot.cubit.searchChanged,
        onStatusChanged: slot.cubit.setStatus,
      ),
      breadcrumb: (context) =>
          sizesBreadcrumb(context, systemId: systemId, labels: labels),
      headerExtras: (slot) => parentHeader(labels),
      extraToolbarActions: (slot) => [
        if (slot.canManage)
          AppButton(
            SizeSystemsKeys.generate,
            variant: AppButtonVariant.outlined,
            size: AppButtonSize.small,
            onPressed: () async {
              final created = await showSizeRangeDialog(
                slot.context,
                sizeGroupId: groupId,
              );
              if (created == true) await slot.cubit.onGenerated();
            },
          ),
      ],
      viewModes: const [AppViewMode.table, AppViewMode.cards],
      capabilities: const CrudCapabilities(
        showCount: true,
        duplicate: false,
        bulkSelection: false,
      ),
      isMutationEffect: (effect) => effect is SizesMutatedEffect,
      flows: CrudFlowsConfig<CatalogSize, SizesListCubit>(
        showEditor: (context, {item, duplicate = false}) =>
            showSizeEditor(context, sizeGroupId: groupId, size: item),
        onSaved: (cubit, {required isNew}) => cubit.onSaved(isNew: isNew),
        itemLabel: (size) => size.name,
        delete: (cubit, size) => cubit.delete(size),
        activate: (cubit, size) => cubit.activate(size.id),
        deactivate: (cubit, size) => cubit.deactivate(size.id),
        labels: _labels,
        isActive: (size) => size.isActive,
        canDelete: (size) => size.canDelete,
        hideDeleteWhenCannotDelete: true,
      ),
      dataSection: (data) =>
          CrudDataSection<CatalogSize, CatalogSizeListQuery, SizesListCubit>(
            data: data,
            columns: [
              DataTableColumn(
                labelKey: SizeSystemsKeys.nameField,
                sortKey: 'name',
                priority: DataTableColumnPriority.primary,
                flex: 3,
                cellBuilder: (_, size) => AppText.raw(size.name),
              ),
              DataTableColumn(
                labelKey: SizeSystemsKeys.code,
                sortKey: 'code',
                priority: DataTableColumnPriority.secondary,
                flex: 2,
                cellBuilder: (_, size) => SizeCodeText(size.code),
              ),
              DataTableColumn(
                labelKey: SizeSystemsKeys.numericValue,
                sortKey: 'value',
                numeric: true,
                priority: DataTableColumnPriority.secondary,
                cellBuilder: (context, size) => AppText.raw(
                  size.numericValue?.toString() ??
                      CommonKeys.noValue.tr(context: context),
                ),
              ),
              DataTableColumn(
                labelKey: SizeSystemsKeys.sortOrder,
                sortKey: 'order',
                numeric: true,
                priority: DataTableColumnPriority.secondary,
                cellBuilder: (_, size) =>
                    AppText.raw(size.sortOrder.toString()),
              ),
              DataTableColumn(
                labelKey: SizeSystemsKeys.productCount,
                numeric: true,
                priority: DataTableColumnPriority.secondary,
                cellBuilder: (_, size) => SizeCountText(size.productCount),
              ),
            ],
            labels: _labels,
            statusColumn: CrudStatusColumnConfig<CatalogSize>(
              labelKey: SizeSystemsKeys.status,
              isActive: (size) => size.isActive,
              badgeBuilder: (_, size) =>
                  SizeStatusBadge(isActive: size.isActive),
            ),
            cardBuilder: _card,
            gridBuilder: _card,
            icon: AppIcons.catalog,
            emptyTitleKey: SizeSystemsKeys.emptySizes,
            emptyDescriptionKey: SizeSystemsKeys.addSize,
            noResultsTitleKey: SizeSystemsKeys.noResults,
            noResultsDescriptionKey: SizeSystemsKeys.noResults,
          ),
    );

Widget _card(BuildContext context, CatalogSize size) => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    AppText.raw(size.name, type: AppTextType.titleMedium),
    SizeCodeText(size.code),
    AppText.raw(
      size.numericValue?.toString() ??
          CommonKeys.noValue.tr(context: context),
    ),
    SizeCountText(size.productCount),
    SizeStatusBadge(isActive: size.isActive),
  ],
);
