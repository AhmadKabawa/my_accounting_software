import 'package:flutter/material.dart' hide MaterialType;
import 'package:accounting_software/app/core/presentation/widgets/app_badge/app_badge.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_table/data_table.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_data_section.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_labels.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_list_config.dart';
import 'package:accounting_software/app/features/catalog/materials/domain/entity/material.dart';
import 'package:accounting_software/app/features/catalog/materials/domain/entity/material_list_query.dart';
import 'package:accounting_software/app/features/catalog/materials/presentation/cubit/materials_list_cubit.dart';
import 'package:accounting_software/app/features/catalog/materials/presentation/localization/materials_keys.dart';

const materialsCrudLabels = CrudLabels(
  edit: MaterialsKeys.edit,
  delete: MaterialsKeys.delete,
  duplicate: MaterialsKeys.duplicate,
  activate: MaterialsKeys.activate,
  deactivate: MaterialsKeys.deactivate,
  deleteConfirmationTitle: MaterialsKeys.deleteTitle,
  deleteConfirmationMessage: MaterialsKeys.deleteMessage,
  deactivateConfirmationTitle: MaterialsKeys.deactivateTitle,
  deactivateConfirmationMessage: MaterialsKeys.deactivateMessage,
);

Widget buildMaterialsDataSection(
  CrudDataContext<CatalogMaterial, MaterialListQuery, MaterialsListCubit> data,
) => CrudDataSection<CatalogMaterial, MaterialListQuery, MaterialsListCubit>(
  data: data,
  columns: [
    DataTableColumn(
      labelKey: MaterialsKeys.materialName,
      sortKey: 'name',
      priority: DataTableColumnPriority.primary,
      flex: 3,
      cellBuilder: (_, item) => AppText.raw(item.name),
    ),
    DataTableColumn(
      labelKey: MaterialsKeys.code,
      sortKey: 'code',
      priority: DataTableColumnPriority.secondary,
      flex: 2,
      cellBuilder: (_, item) => Directionality(
        textDirection: TextDirection.ltr,
        child: AppText.raw(item.code),
      ),
    ),
    DataTableColumn(
      labelKey: MaterialsKeys.type,
      priority: DataTableColumnPriority.hiddenOnMobile,
      flex: 2,
      cellBuilder: (_, item) => AppText(switch (item.materialType) {
        MaterialType.natural => MaterialsKeys.natural,
        MaterialType.synthetic => MaterialsKeys.synthetic,
        MaterialType.blended => MaterialsKeys.blended,
        null => MaterialsKeys.notSpecified,
      }),
    ),
  ],
  labels: materialsCrudLabels,
  cardBuilder: (_, item) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      AppText.raw(item.name, type: AppTextType.titleSmall),
      Directionality(
        textDirection: TextDirection.ltr,
        child: AppText.raw(item.code),
      ),
      AppText(switch (item.materialType) {
        MaterialType.natural => MaterialsKeys.natural,
        MaterialType.synthetic => MaterialsKeys.synthetic,
        MaterialType.blended => MaterialsKeys.blended,
        null => MaterialsKeys.notSpecified,
      }),
      AppBadge(
        label: item.isActive ? MaterialsKeys.active : MaterialsKeys.inactive,
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
      AppText(switch (item.materialType) {
        MaterialType.natural => MaterialsKeys.natural,
        MaterialType.synthetic => MaterialsKeys.synthetic,
        MaterialType.blended => MaterialsKeys.blended,
        null => MaterialsKeys.notSpecified,
      }),
      AppBadge(
        label: item.isActive ? MaterialsKeys.active : MaterialsKeys.inactive,
        tone: item.isActive ? AppBadgeTone.success : AppBadgeTone.neutral,
        size: AppBadgeSize.small,
      ),
    ],
  ),
  statusColumn: CrudStatusColumnConfig<CatalogMaterial>(
    labelKey: MaterialsKeys.status,
    sortKey: 'status',
    isActive: (item) => item.isActive,
    badgeBuilder: (_, item) => AppBadge(
      label: item.isActive ? MaterialsKeys.active : MaterialsKeys.inactive,
      tone: item.isActive ? AppBadgeTone.success : AppBadgeTone.neutral,
      size: AppBadgeSize.small,
    ),
  ),
  icon: AppIcons.catalog,
  emptyTitleKey: MaterialsKeys.empty,
  emptyDescriptionKey: MaterialsKeys.emptyDescription,
  noResultsTitleKey: MaterialsKeys.noResults,
  noResultsDescriptionKey: MaterialsKeys.noResultsDescription,
);
