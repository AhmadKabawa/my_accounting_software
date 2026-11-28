import 'package:go_router/go_router.dart';
import 'package:accounting_software/app/core/access/permissions.dart';
import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/core/localization/keys/nav_keys.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_breadcrumb/app_breadcrumb.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_filter_bar/filter_bar.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_searchable_dropdown/searchable_dropdown.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_list_config.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_flows_config.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/domain/entity/care_instruction.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/domain/entity/care_instruction_list_query.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/presentation/cubit/care_instructions_list_cubit.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/presentation/cubit/care_instructions_list_effect.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/presentation/dialogs/care_instruction_editor_launcher.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/presentation/localization/care_instructions_keys.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/presentation/widgets/care_instructions_data_section.dart';
import 'package:accounting_software/app/features/catalog/presentation/routing/catalog_routes.dart';

AppKey careTypeLabel(CareType type) => switch (type) {
  CareType.washing => CareInstructionsKeys.washing,
  CareType.drying => CareInstructionsKeys.drying,
  CareType.ironing => CareInstructionsKeys.ironing,
  CareType.bleaching => CareInstructionsKeys.bleaching,
  CareType.dryCleaning => CareInstructionsKeys.dryCleaning,
};

CrudListConfig<
  CareInstruction,
  CareInstructionListQuery,
  CareInstructionsListCubit,
  CareInstructionsListEffect
>
get careInstructionsListConfig => CrudListConfig(
  screenId: 'catalog.careInstructions',
  titleKey: CareInstructionsKeys.title,
  manageAccess: Permissions.masterData.manage,
  searchHintKey: CareInstructionsKeys.searchHint,
  addLabelKey: CareInstructionsKeys.add,
  createCubit: () => sl<CareInstructionsListCubit>(),
  rowId: (item) => item.id,
  itemLabel: (item) => item.name,
  sort: CrudSortConfig<CareInstructionListQuery, CareInstructionsListCubit>(
    options: const [],
    current: (_) => const [],
    tableKey: (_) => null,
    tableAscending: (_) => true,
    apply: (_, _) {},
    applyTable: (_, _) {},
  ),
  filterControls: (slot) => [
    SearchableDropdown<CareInstructionStatusFilter>(
      options: const [
        CareInstructionStatusFilter.active,
        CareInstructionStatusFilter.inactive,
      ],
      labelKey: CareInstructionsKeys.status,
      optionLabel: (value) =>
          (value == CareInstructionStatusFilter.active
                  ? CareInstructionsKeys.active
                  : CareInstructionsKeys.inactive)
              .tr(context: slot.context),
      value: slot.state.query.status == CareInstructionStatusFilter.all
          ? null
          : slot.state.query.status,
      clearable: false,
      mode: SearchableDropdownMode.panel,
      allOptionLabel: CareInstructionsKeys.allStatuses,
      onChanged: (value) =>
          slot.cubit.setStatus(value ?? CareInstructionStatusFilter.all),
    ),
    SearchableDropdown<CareType>(
      options: CareType.values,
      labelKey: CareInstructionsKeys.careType,
      optionLabel: (value) => careTypeLabel(value).tr(context: slot.context),
      value: slot.state.query.careType,
      clearable: true,
      mode: SearchableDropdownMode.panel,
      onChanged: slot.cubit.setCareType,
    ),
  ],
  activeFilters: (slot) => [
    if (slot.state.query.search.isNotEmpty)
      FilterBarFilter(
        id: FilterBar.searchFilterId,
        label: CareInstructionsKeys.searchHint,
        value: slot.state.query.search,
        onRemove: () => slot.cubit.searchChanged(''),
      ),
    if (slot.state.query.careType != null)
      FilterBarFilter(
        id: 'careType',
        label: CareInstructionsKeys.careType,
        value: careTypeLabel(
          slot.state.query.careType!,
        ).tr(context: slot.context),
        onRemove: () => slot.cubit.setCareType(null),
      ),
    if (slot.state.query.status != CareInstructionStatusFilter.all)
      FilterBarFilter(
        id: 'status',
        label: CareInstructionsKeys.status,
        value:
            (slot.state.query.status == CareInstructionStatusFilter.active
                    ? CareInstructionsKeys.active
                    : CareInstructionsKeys.inactive)
                .tr(context: slot.context),
        onRemove: () => slot.cubit.setStatus(CareInstructionStatusFilter.all),
      ),
  ],
  breadcrumb: (context) => AppBreadcrumb(
    items: [
      AppBreadcrumbItem(
        label: NavKeys.catalog,
        onTap: () => context.go(CatalogRoutes.hub.path),
      ),
      const AppBreadcrumbItem(label: CareInstructionsKeys.title),
    ],
  ),
  capabilities: const CrudCapabilities(duplicate: false, bulkSelection: false),
  isMutationEffect: (effect) => effect is CareInstructionsMutatedEffect,
  flows: CrudFlowsConfig<CareInstruction, CareInstructionsListCubit>(
    showEditor: (context, {item, duplicate = false}) =>
        showCareInstructionEditor(context, item: item),
    onSaved: (cubit, {required isNew}) => cubit.onSaved(isNew: isNew),
    itemLabel: (item) => item.name,
    delete: (cubit, item) => cubit.delete(item),
    activate: (cubit, item) => cubit.activate(item.id),
    deactivate: (cubit, item) => cubit.deactivate(item.id),
    labels: careInstructionsCrudLabels,
    messageArgs: (item) => {'name': item.name},
    isActive: (item) => item.isActive,
    canDelete: (item) => !item.isUsed,
    hideDeleteWhenCannotDelete: true,
  ),
  dataSection: buildCareInstructionsDataSection,
);
