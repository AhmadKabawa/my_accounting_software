import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/foundation/date/date_only.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_badge/app_badge.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_table/data_table.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_data_section.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_labels.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_list_config.dart';
import 'package:accounting_software/app/features/catalog/seasons/domain/entity/season.dart';
import 'package:accounting_software/app/features/catalog/seasons/domain/entity/season_list_query.dart';
import 'package:accounting_software/app/features/catalog/seasons/presentation/cubit/seasons_list_cubit.dart';
import 'package:accounting_software/app/features/catalog/seasons/presentation/localization/seasons_keys.dart';

const seasonsCrudLabels = CrudLabels(
  edit: SeasonsKeys.edit,
  delete: SeasonsKeys.delete,
  duplicate: SeasonsKeys.duplicate,
  activate: SeasonsKeys.activate,
  deactivate: SeasonsKeys.deactivate,
  deleteConfirmationTitle: SeasonsKeys.deleteTitle,
  deleteConfirmationMessage: SeasonsKeys.deleteMessage,
  deactivateConfirmationTitle: SeasonsKeys.deactivateTitle,
  deactivateConfirmationMessage: SeasonsKeys.deactivateMessage,
);

Widget buildSeasonsDataSection(
  CrudDataContext<CatalogSeason, SeasonListQuery, SeasonsListCubit> data,
) => CrudDataSection<CatalogSeason, SeasonListQuery, SeasonsListCubit>(
  data: data,
  columns: [
    DataTableColumn(
      labelKey: SeasonsKeys.seasonName,
      sortKey: 'name',
      priority: DataTableColumnPriority.primary,
      flex: 3,
      cellBuilder: (_, item) => AppText.raw(item.name),
    ),
    DataTableColumn(
      labelKey: SeasonsKeys.startDate,
      sortKey: 'startDate',
      priority: DataTableColumnPriority.secondary,
      flex: 2,
      cellBuilder: (_, item) => AppText.raw(
        item.startDate == null ? '—' : DateOnly.toApiString(item.startDate!),
      ),
    ),
    DataTableColumn(
      labelKey: SeasonsKeys.type,
      priority: DataTableColumnPriority.hiddenOnMobile,
      flex: 2,
      cellBuilder: (_, item) => AppText(switch (item.seasonType) {
        SeasonType.summer => SeasonsKeys.summer,
        SeasonType.winter => SeasonsKeys.winter,
        SeasonType.spring => SeasonsKeys.spring,
        SeasonType.autumn => SeasonsKeys.autumn,
        null => SeasonsKeys.notSpecified,
      }),
    ),
  ],
  labels: seasonsCrudLabels,
  cardBuilder: (_, item) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      AppText.raw(item.name, type: AppTextType.titleSmall),
      AppText.raw(item.code),
      AppText(switch (item.seasonType) {
        SeasonType.summer => SeasonsKeys.summer,
        SeasonType.winter => SeasonsKeys.winter,
        SeasonType.spring => SeasonsKeys.spring,
        SeasonType.autumn => SeasonsKeys.autumn,
        null => SeasonsKeys.notSpecified,
      }),
      AppText.raw(item.startDate == null
          ? '—'
          : DateOnly.toApiString(item.startDate!)),
      AppBadge(
        label: item.isActive ? SeasonsKeys.active : SeasonsKeys.inactive,
        tone: item.isActive ? AppBadgeTone.success : AppBadgeTone.neutral,
        size: AppBadgeSize.small,
      ),
    ],
  ),
  gridBuilder: (_, item) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      AppText.raw(item.name, type: AppTextType.titleSmall),
      AppText.raw(item.code),
      AppText(switch (item.seasonType) {
        SeasonType.summer => SeasonsKeys.summer,
        SeasonType.winter => SeasonsKeys.winter,
        SeasonType.spring => SeasonsKeys.spring,
        SeasonType.autumn => SeasonsKeys.autumn,
        null => SeasonsKeys.notSpecified,
      }),
      AppText.raw(item.startDate == null
          ? '—'
          : DateOnly.toApiString(item.startDate!)),
      AppBadge(
        label: item.isActive ? SeasonsKeys.active : SeasonsKeys.inactive,
        tone: item.isActive ? AppBadgeTone.success : AppBadgeTone.neutral,
        size: AppBadgeSize.small,
      ),
    ],
  ),
  statusColumn: CrudStatusColumnConfig<CatalogSeason>(
    labelKey: SeasonsKeys.status,
    sortKey: 'status',
    isActive: (item) => item.isActive,
    badgeBuilder: (_, item) => AppBadge(
      label: item.isActive ? SeasonsKeys.active : SeasonsKeys.inactive,
      tone: item.isActive ? AppBadgeTone.success : AppBadgeTone.neutral,
      size: AppBadgeSize.small,
    ),
  ),
  icon: AppIcons.catalog,
  emptyTitleKey: SeasonsKeys.empty,
  emptyDescriptionKey: SeasonsKeys.emptyDescription,
  noResultsTitleKey: SeasonsKeys.noResults,
  noResultsDescriptionKey: SeasonsKeys.noResultsDescription,
);
