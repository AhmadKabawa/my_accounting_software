import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:accounting_software/app/core/access/permissions.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/core/localization/keys/nav_keys.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_breadcrumb/app_breadcrumb.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_card/app_card.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_table/data_table.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_data_section.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_flows_config.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_labels.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_list_config.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_view/app_view_mode.dart';
import 'package:accounting_software/app/features/catalog/units/domain/entity/catalog_unit.dart';
import 'package:accounting_software/app/features/catalog/units/domain/entity/unit_list_query.dart';
import 'package:accounting_software/app/features/catalog/units/presentation/cubit/units_list/units_list_cubit.dart';
import 'package:accounting_software/app/features/catalog/units/presentation/cubit/units_list/units_list_effect.dart';
import 'package:accounting_software/app/features/catalog/units/presentation/dialogs/unit_editor_launcher.dart';
import 'package:accounting_software/app/features/catalog/units/presentation/localization/units_keys.dart';
import 'package:accounting_software/app/features/catalog/presentation/routing/catalog_routes.dart';

const _labels = CrudLabels(
  edit: UnitsKeys.edit,
  delete: UnitsKeys.delete,
  activate: UnitsKeys.activate,
  deactivate: UnitsKeys.deactivate,
  deleteConfirmationTitle: UnitsKeys.delete,
  deleteConfirmationMessage: UnitsKeys.confirmDelete,
  deactivateConfirmationTitle: UnitsKeys.deactivateTitle,
  deactivateConfirmationMessage: UnitsKeys.deactivateMessage,
);

String _unitTypeLabel(BuildContext context, UnitType type) => switch (type) {
  UnitType.weight => UnitsKeys.weight.tr(context: context),
  UnitType.length => UnitsKeys.length.tr(context: context),
  UnitType.volume => UnitsKeys.volume.tr(context: context),
  UnitType.piece => UnitsKeys.piece.tr(context: context),
};

CrudListConfig<CatalogUnit, UnitListQuery, UnitsListCubit, UnitsListEffect>
get unitsListConfig => CrudListConfig(
  screenId: 'catalog.units',
  titleKey: UnitsKeys.title,
  manageAccess: Permissions.masterData.manage,
  searchHintKey: UnitsKeys.search,
  addLabelKey: UnitsKeys.add,
  createCubit: () => sl<UnitsListCubit>(),
  rowId: (unit) => unit.id,
  itemLabel: (unit) => unit.name,
  sort: CrudSortConfig<UnitListQuery, UnitsListCubit>(
    current: (_) => const [],
    tableKey: (_) => null,
    tableAscending: (_) => true,
    apply: (_, __) {},
    applyTable: (_, __) {},
  ),
  filterControls: (_) => const [],
  activeFilters: (_) => const [],
  breadcrumb: (context) => AppBreadcrumb(
    items: [
      AppBreadcrumbItem(
        label: NavKeys.catalog,
        onTap: () => context.go(CatalogRoutes.hub.path),
      ),
      const AppBreadcrumbItem(label: UnitsKeys.title),
    ],
  ),
  viewModes: const [AppViewMode.table, AppViewMode.cards],
  capabilities: const CrudCapabilities(duplicate: false, bulkSelection: false),
  flows: CrudFlowsConfig<CatalogUnit, UnitsListCubit>(
    showEditor: (context, {item, duplicate = false}) =>
        showUnitEditor(context, unit: item),
    onSaved: (cubit, {required isNew}) => cubit.onUnitSaved(isNew: isNew),
    itemLabel: (unit) => unit.name,
    delete: (cubit, unit) => cubit.delete(unit),
    activate: (cubit, unit) => cubit.activate(unit.id),
    deactivate: (cubit, unit) => cubit.deactivate(unit.id),
    labels: _labels,
    isActive: (unit) => unit.isActive,
    canDelete: (unit) => unit.usageCount == 0,
  ),
  dataSection: (data) =>
      CrudDataSection<CatalogUnit, UnitListQuery, UnitsListCubit>(
        data: data,
        columns: [
          DataTableColumn(
            labelKey: UnitsKeys.unitName,
            priority: DataTableColumnPriority.primary,
            flex: 3,
            cellBuilder: (_, unit) => AppText.raw(unit.name),
          ),
          DataTableColumn(
            labelKey: UnitsKeys.symbol,
            priority: DataTableColumnPriority.primary,
            cellBuilder: (_, unit) => AppText.raw(unit.symbol),
          ),
          DataTableColumn(
            labelKey: UnitsKeys.type,
            priority: DataTableColumnPriority.secondary,
            cellBuilder: (context, unit) =>
                AppText.raw(_unitTypeLabel(context, unit.type)),
          ),
          DataTableColumn(
            labelKey: UnitsKeys.usage,
            numeric: true,
            priority: DataTableColumnPriority.secondary,
            cellBuilder: (_, unit) => AppText.raw(
              unit.usageCount?.toString() ?? UnitsKeys.unknownUsage.tr(),
            ),
          ),
        ],
        labels: _labels,
        statusColumn: CrudStatusColumnConfig<CatalogUnit>(
          labelKey: UnitsKeys.status,
          isActive: (unit) => unit.isActive,
          badgeBuilder: (context, unit) =>
              AppText(unit.isActive ? UnitsKeys.active : UnitsKeys.inactive),
        ),
        cardBuilder: (context, unit) => _UnitCard(unit: unit),
        gridBuilder: (context, unit) => _UnitCard(unit: unit),
        icon: AppIcons.catalog,
        emptyTitleKey: UnitsKeys.empty,
        emptyDescriptionKey: UnitsKeys.emptyDescription,
        noResultsTitleKey: UnitsKeys.noResults,
        noResultsDescriptionKey: UnitsKeys.noResultsDescription,
      ),
);

class _UnitCard extends StatelessWidget {
  const _UnitCard({required this.unit});
  final CatalogUnit unit;

  @override
  Widget build(BuildContext context) => AppCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText.raw(unit.name, type: AppTextType.titleMedium),
        context.ui.spacing.gap(AppSpacing.xs),
        AppText.raw(unit.symbol),
        context.ui.spacing.gap(AppSpacing.xs),
        AppText.raw(_unitTypeLabel(context, unit.type)),
        context.ui.spacing.gap(AppSpacing.xs),
        AppText(unit.isActive ? UnitsKeys.active : UnitsKeys.inactive),
      ],
    ),
  );
}
