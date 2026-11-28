import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_badge/app_badge.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_table/data_table.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_data_section.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_labels.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_list_config.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/domain/entity/care_instruction.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/domain/entity/care_instruction_list_query.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/presentation/cubit/care_instructions_list_cubit.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/presentation/localization/care_instructions_keys.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/presentation/care_type_presentation.dart';

const careInstructionsCrudLabels = CrudLabels(
  edit: CareInstructionsKeys.edit,
  delete: CareInstructionsKeys.delete,
  activate: CareInstructionsKeys.activate,
  deactivate: CareInstructionsKeys.deactivate,
  deleteConfirmationTitle: CareInstructionsKeys.deleteTitle,
  deleteConfirmationMessage: CareInstructionsKeys.deleteMessage,
  deactivateConfirmationTitle: CareInstructionsKeys.deactivateTitle,
  deactivateConfirmationMessage: CareInstructionsKeys.deactivateMessage,
);

Widget buildCareInstructionsDataSection(
  CrudDataContext<CareInstruction, CareInstructionListQuery, CareInstructionsListCubit> data,
) => CrudDataSection<CareInstruction, CareInstructionListQuery, CareInstructionsListCubit>(
  data: data,
  columns: [
    DataTableColumn(
      labelKey: CareInstructionsKeys.name,
      priority: DataTableColumnPriority.primary,
      flex: 3,
      cellBuilder: (_, item) => AppText.raw(item.name),
    ),
    DataTableColumn(
      labelKey: CareInstructionsKeys.code,
      priority: DataTableColumnPriority.secondary,
      flex: 2,
      cellBuilder: (_, item) => Directionality(
        textDirection: TextDirection.ltr,
        child: AppText.raw(item.code),
      ),
    ),
    DataTableColumn(
      labelKey: CareInstructionsKeys.careType,
      priority: DataTableColumnPriority.secondary,
      flex: 2,
      cellBuilder: (_, item) => AppText(careTypeLabel(item.careType)),
    ),
  ],
  labels: careInstructionsCrudLabels,
  cardBuilder: (_, item) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      AppText.raw(item.name, type: AppTextType.titleSmall),
      Directionality(textDirection: TextDirection.ltr, child: AppText.raw(item.code)),
      AppText(careTypeLabel(item.careType)),
      AppBadge(
        label: item.isActive ? CareInstructionsKeys.active : CareInstructionsKeys.inactive,
        tone: item.isActive ? AppBadgeTone.success : AppBadgeTone.neutral,
        size: AppBadgeSize.small,
      ),
    ],
  ),
  gridBuilder: (_, item) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      AppText.raw(item.name, type: AppTextType.titleSmall),
      Directionality(textDirection: TextDirection.ltr, child: AppText.raw(item.code)),
      AppText(careTypeLabel(item.careType)),
      AppBadge(
        label: item.isActive ? CareInstructionsKeys.active : CareInstructionsKeys.inactive,
        tone: item.isActive ? AppBadgeTone.success : AppBadgeTone.neutral,
        size: AppBadgeSize.small,
      ),
    ],
  ),
  statusColumn: CrudStatusColumnConfig<CareInstruction>(
    labelKey: CareInstructionsKeys.status,
    isActive: (item) => item.isActive,
    badgeBuilder: (_, item) => AppBadge(
      label: item.isActive ? CareInstructionsKeys.active : CareInstructionsKeys.inactive,
      tone: item.isActive ? AppBadgeTone.success : AppBadgeTone.neutral,
      size: AppBadgeSize.small,
    ),
  ),
  icon: AppIcons.catalog,
  emptyTitleKey: CareInstructionsKeys.empty,
  emptyDescriptionKey: CareInstructionsKeys.emptyDescription,
  noResultsTitleKey: CareInstructionsKeys.noResults,
  noResultsDescriptionKey: CareInstructionsKeys.noResultsDescription,
);
