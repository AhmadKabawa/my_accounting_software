import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_badge/app_badge.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_table/data_table.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_data_section.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_labels.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_list_config.dart';
import 'package:accounting_software/app/features/catalog/fabric_types/domain/entity/fabric_type.dart';
import 'package:accounting_software/app/features/catalog/fabric_types/domain/entity/fabric_type_list_query.dart';
import 'package:accounting_software/app/features/catalog/fabric_types/presentation/cubit/fabric_types_list_cubit.dart';
import 'package:accounting_software/app/features/catalog/fabric_types/presentation/localization/fabric_types_keys.dart';

const fabricTypesCrudLabels = CrudLabels(
  edit: FabricTypesKeys.edit,
  delete: FabricTypesKeys.delete,
  duplicate: FabricTypesKeys.duplicate,
  activate: FabricTypesKeys.activate,
  deactivate: FabricTypesKeys.deactivate,
  deleteConfirmationTitle: FabricTypesKeys.deleteTitle,
  deleteConfirmationMessage: FabricTypesKeys.deleteMessage,
  deactivateConfirmationTitle: FabricTypesKeys.deactivateTitle,
  deactivateConfirmationMessage: FabricTypesKeys.deactivateMessage,
);

Widget buildFabricTypesDataSection(
  CrudDataContext<CatalogFabricType, FabricTypeListQuery, FabricTypesListCubit>
  data,
) =>
    CrudDataSection<
      CatalogFabricType,
      FabricTypeListQuery,
      FabricTypesListCubit
    >(
      data: data,
      columns: [
        DataTableColumn(
          labelKey: FabricTypesKeys.fabricTypeName,
          sortKey: 'name',
          priority: DataTableColumnPriority.primary,
          flex: 3,
          cellBuilder: (_, item) => AppText.raw(item.name),
        ),
        DataTableColumn(
          labelKey: FabricTypesKeys.code,
          sortKey: 'code',
          priority: DataTableColumnPriority.secondary,
          flex: 2,
          cellBuilder: (_, item) => Directionality(
            textDirection: TextDirection.ltr,
            child: AppText.raw(item.code),
          ),
        ),
        DataTableColumn(
          labelKey: FabricTypesKeys.category,
          priority: DataTableColumnPriority.hiddenOnMobile,
          flex: 2,
          cellBuilder: (_, item) => AppText(switch (item.fabricCategory) {
            FabricCategory.knit => FabricTypesKeys.knit,
            FabricCategory.woven => FabricTypesKeys.woven,
            FabricCategory.fleece => FabricTypesKeys.fleece,
            null => FabricTypesKeys.notSpecified,
          }),
        ),
      ],
      labels: fabricTypesCrudLabels,
      cardBuilder: (_, item) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.raw(item.name, type: AppTextType.titleSmall),
          Directionality(
            textDirection: TextDirection.ltr,
            child: AppText.raw(item.code),
          ),
          AppText(switch (item.fabricCategory) {
            FabricCategory.knit => FabricTypesKeys.knit,
            FabricCategory.woven => FabricTypesKeys.woven,
            FabricCategory.fleece => FabricTypesKeys.fleece,
            null => FabricTypesKeys.notSpecified,
          }),
          AppBadge(
            label: item.isActive
                ? FabricTypesKeys.active
                : FabricTypesKeys.inactive,
            tone: item.isActive ? AppBadgeTone.success : AppBadgeTone.neutral,
            size: AppBadgeSize.small,
          ),
        ],
      ),
      gridBuilder: (_, item) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.raw(item.name, type: AppTextType.titleSmall),
          Directionality(
            textDirection: TextDirection.ltr,
            child: AppText.raw(item.code),
          ),
          AppText(switch (item.fabricCategory) {
            FabricCategory.knit => FabricTypesKeys.knit,
            FabricCategory.woven => FabricTypesKeys.woven,
            FabricCategory.fleece => FabricTypesKeys.fleece,
            null => FabricTypesKeys.notSpecified,
          }),
          AppBadge(
            label: item.isActive
                ? FabricTypesKeys.active
                : FabricTypesKeys.inactive,
            tone: item.isActive ? AppBadgeTone.success : AppBadgeTone.neutral,
            size: AppBadgeSize.small,
          ),
        ],
      ),
      statusColumn: CrudStatusColumnConfig<CatalogFabricType>(
        labelKey: FabricTypesKeys.status,
        sortKey: 'status',
        isActive: (item) => item.isActive,
        badgeBuilder: (_, item) => AppBadge(
          label: item.isActive
              ? FabricTypesKeys.active
              : FabricTypesKeys.inactive,
          tone: item.isActive ? AppBadgeTone.success : AppBadgeTone.neutral,
          size: AppBadgeSize.small,
        ),
      ),
      icon: AppIcons.catalog,
      emptyTitleKey: FabricTypesKeys.empty,
      emptyDescriptionKey: FabricTypesKeys.emptyDescription,
      noResultsTitleKey: FabricTypesKeys.noResults,
      noResultsDescriptionKey: FabricTypesKeys.noResultsDescription,
    );
