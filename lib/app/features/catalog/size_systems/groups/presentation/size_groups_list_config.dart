import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:accounting_software/app/core/access/permissions.dart';
import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_table/data_table.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_view/app_view_mode.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_filter_bar/filter_bar.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_row_actions/app_row_actions.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_searchable_dropdown/searchable_dropdown.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_data_section.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_flows_config.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_labels.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_list_config.dart';
import 'package:accounting_software/app/features/catalog/size_systems/groups/domain/entity/gender_option.dart';
import 'package:accounting_software/app/features/catalog/size_systems/groups/domain/entity/size_group.dart';
import 'package:accounting_software/app/features/catalog/size_systems/groups/domain/entity/size_group_list_query.dart';
import 'package:accounting_software/app/features/catalog/size_systems/groups/presentation/cubit/gender_options/gender_options_cubit.dart';
import 'package:accounting_software/app/features/catalog/size_systems/groups/presentation/cubit/size_groups_list/size_groups_list_cubit.dart';
import 'package:accounting_software/app/features/catalog/size_systems/groups/presentation/cubit/size_groups_list/size_groups_list_effect.dart';
import 'package:accounting_software/app/features/catalog/size_systems/groups/presentation/dialogs/size_group_editor_launcher.dart';
import 'package:accounting_software/app/features/catalog/size_systems/presentation/localization/size_systems_keys.dart';
import 'package:accounting_software/app/features/catalog/size_systems/presentation/routing/size_systems_routes.dart';
import 'package:accounting_software/app/features/catalog/size_systems/presentation/widgets/size_breadcrumbs.dart';
import 'package:accounting_software/app/features/catalog/size_systems/presentation/widgets/size_filter_bar.dart';
import 'package:accounting_software/app/features/catalog/size_systems/presentation/widgets/size_list_cells.dart';
import 'package:accounting_software/app/features/catalog/size_systems/presentation/widgets/size_status_badge.dart';

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

void _openSizes(
  BuildContext? context,
  int systemId,
  SizeGroup group,
  SizeRouteContext? labels,
) {
  if (context == null) return;
  context.go(
    SizeSystemsRoutes.sizes(systemId, group.id),
    extra: SizeRouteContext(
      systemName: labels?.systemName,
      groupName: group.name,
    ),
  );
}

/// The groups of one system. [systemId] comes from the route path; [labels]
/// (parent names) is optional and only decorates the header.
CrudListConfig<
  SizeGroup,
  SizeGroupListQuery,
  SizeGroupsListCubit,
  SizeGroupsListEffect
>
sizeGroupsListConfig(int systemId, {SizeRouteContext? labels}) =>
    CrudListConfig(
      screenId: 'catalog.sizeSystemGroups',
      titleKey: SizeSystemsKeys.groupsTitle,
      manageAccess: Permissions.masterData.manage,
      searchHintKey: SizeSystemsKeys.searchHint,
      addLabelKey: SizeSystemsKeys.addGroup,
      createCubit: () => sl<SizeGroupsListCubit>(param1: systemId),
      rowId: (group) => group.id,
      itemLabel: (group) => group.name,
      sort: CrudSortConfig<SizeGroupListQuery, SizeGroupsListCubit>(
        options: SizeFilterBar.groupSortOptions,
        maxSorts: 1,
        current: (query) => [
          FilterBarSort(query.sortField.name, query.sortAscending),
        ],
        tableKey: (query) => query.sortField.name,
        tableAscending: (query) => query.sortAscending,
        apply: (cubit, sorts) {
          if (sorts.isEmpty) return;
          final field = SizeGroupSortField.tryParse(sorts.first.key);
          if (field != null) cubit.setSort(field, sorts.first.ascending);
        },
        applyTable: (cubit, sort) {
          final field = SizeGroupSortField.tryParse(sort.key);
          if (field != null) cubit.setSort(field, sort.ascending);
        },
      ),
      filterControls: (slot) => [
        SizeFilterBar.statusControl(
          slot.context,
          slot.state.query.status,
          slot.cubit.setStatus,
        ),
        BlocBuilder<GenderOptionsCubit, GenderOptionsState>(
          builder: (context, state) {
            final id = slot.state.query.genderId;
            GenderOption? selected;
            for (final gender in state.genders) {
              if (gender.id == id) selected = gender;
            }
            return SearchableDropdown<GenderOption>(
              options: state.genders,
              labelKey: SizeSystemsKeys.gender,
              optionLabel: (gender) => gender.name,
              value: selected,
              allOptionLabel: SizeSystemsKeys.allGenders,
              mode: SearchableDropdownMode.panel,
              onChanged: (gender) => slot.cubit.setGender(gender?.id),
            );
          },
        ),
      ],
      activeFilters: (slot) => SizeFilterBar.activeFilters(
        slot.context,
        search: slot.state.query.search,
        status: slot.state.query.status,
        onSearchChanged: slot.cubit.searchChanged,
        onStatusChanged: slot.cubit.setStatus,
        extra: [
          if (slot.state.query.genderId != null)
            FilterBarFilter(
              id: 'gender',
              label: SizeSystemsKeys.gender,
              value:
                  slot.context.read<GenderOptionsCubit>().state.nameOf(
                    slot.state.query.genderId,
                  ) ??
                  '—',
              onRemove: () => slot.cubit.setGender(null),
            ),
        ],
      ),
      breadcrumb: groupsBreadcrumb,
      headerExtras: (slot) => parentHeader(labels),
      viewModes: const [AppViewMode.table, AppViewMode.cards],
      capabilities: const CrudCapabilities(
        showCount: true,
        duplicate: false,
        bulkSelection: false,
      ),
      providersWrapper: (child) => BlocProvider<GenderOptionsCubit>(
        create: (_) => sl<GenderOptionsCubit>()..load(),
        child: child,
      ),
      isMutationEffect: (effect) => effect is SizeGroupsMutatedEffect,
      flows: CrudFlowsConfig<SizeGroup, SizeGroupsListCubit>(
        showEditor: (context, {item, duplicate = false}) => showSizeGroupEditor(
          context,
          sizeSystemId: systemId,
          genders: context.read<GenderOptionsCubit>().state.genders,
          group: item,
        ),
        onSaved: (cubit, {required isNew}) => cubit.onSaved(isNew: isNew),
        itemLabel: (group) => group.name,
        delete: (cubit, group) => cubit.delete(group),
        activate: (cubit, group) => cubit.activate(group.id),
        deactivate: (cubit, group) => cubit.deactivate(group.id),
        labels: _labels,
        isActive: (group) => group.isActive,
        canDelete: (group) => group.canDelete,
        hideDeleteWhenCannotDelete: true,
      ),
      dataSection: (data) =>
          CrudDataSection<SizeGroup, SizeGroupListQuery, SizeGroupsListCubit>(
            data: data,
            onRowTap: (group) =>
                _openSizes(data.context, systemId, group, labels),
            extraRowActions: (context, group) => [
              AppRowAction(
                icon: AppIcons.catalog,
                labelKey: SizeSystemsKeys.openSizes,
                onPressed: () => _openSizes(context, systemId, group, labels),
              ),
            ],
            columns: [
              DataTableColumn(
                labelKey: SizeSystemsKeys.nameField,
                sortKey: 'name',
                priority: DataTableColumnPriority.primary,
                flex: 3,
                cellBuilder: (_, group) => AppText.raw(group.name),
              ),
              DataTableColumn(
                labelKey: SizeSystemsKeys.code,
                sortKey: 'code',
                priority: DataTableColumnPriority.secondary,
                flex: 2,
                cellBuilder: (_, group) => SizeCodeText(group.code),
              ),
              DataTableColumn(
                labelKey: SizeSystemsKeys.gender,
                priority: DataTableColumnPriority.secondary,
                cellBuilder: (_, group) =>
                    BlocBuilder<GenderOptionsCubit, GenderOptionsState>(
                      builder: (_, state) =>
                          AppText.raw(state.nameOf(group.genderId) ?? '—'),
                    ),
              ),
              DataTableColumn(
                labelKey: SizeSystemsKeys.sizeCount,
                numeric: true,
                priority: DataTableColumnPriority.secondary,
                cellBuilder: (_, group) => SizeCountText(group.sizeCount),
              ),
              DataTableColumn(
                labelKey: SizeSystemsKeys.productTypeCount,
                numeric: true,
                priority: DataTableColumnPriority.secondary,
                cellBuilder: (_, group) =>
                    SizeCountText(group.productTypeCount),
              ),
            ],
            labels: _labels,
            statusColumn: CrudStatusColumnConfig<SizeGroup>(
              labelKey: SizeSystemsKeys.status,
              isActive: (group) => group.isActive,
              badgeBuilder: (_, group) =>
                  SizeStatusBadge(isActive: group.isActive),
            ),
            cardBuilder: _card,
            gridBuilder: _card,
            icon: AppIcons.catalog,
            emptyTitleKey: SizeSystemsKeys.emptyGroups,
            emptyDescriptionKey: SizeSystemsKeys.addGroup,
            noResultsTitleKey: SizeSystemsKeys.noResults,
            noResultsDescriptionKey: SizeSystemsKeys.noResults,
          ),
    );

Widget _card(BuildContext context, SizeGroup group) => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    AppText.raw(group.name, type: AppTextType.titleMedium),
    SizeCodeText(group.code),
    SizeCountText(group.sizeCount),
    SizeStatusBadge(isActive: group.isActive),
  ],
);
