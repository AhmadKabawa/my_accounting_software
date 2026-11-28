import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/foundation/date/date_only.dart';
import 'package:accounting_software/app/core/localization/keys/common_keys.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_badge/app_badge.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_table/data_table.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_logo_thumb/app_logo_thumb.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_data_section.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_labels.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_list_config.dart';
import 'package:accounting_software/app/features/catalog/collections/domain/entity/collection.dart';
import 'package:accounting_software/app/features/catalog/collections/domain/entity/collection_list_query.dart';
import 'package:accounting_software/app/features/catalog/collections/presentation/cubit/collections_list_cubit.dart';
import 'package:accounting_software/app/features/catalog/collections/presentation/localization/collections_keys.dart';

const collectionsCrudLabels = CrudLabels(
  edit: CollectionsKeys.edit,
  delete: CollectionsKeys.delete,
  duplicate: CollectionsKeys.duplicate,
  activate: CollectionsKeys.activate,
  deactivate: CollectionsKeys.deactivate,
  deleteConfirmationTitle: CollectionsKeys.deleteTitle,
  deleteConfirmationMessage: CollectionsKeys.deleteMessage,
  deactivateConfirmationTitle: CollectionsKeys.deactivateTitle,
  deactivateConfirmationMessage: CollectionsKeys.deactivateMessage,
);

Widget buildCollectionsDataSection(
  CrudDataContext<CatalogCollection, CollectionListQuery, CollectionsListCubit>
  data,
) =>
    CrudDataSection<
      CatalogCollection,
      CollectionListQuery,
      CollectionsListCubit
    >(
      data: data,
      columns: [
        DataTableColumn(
          labelKey: CollectionsKeys.collectionName,
          sortKey: 'name',
          priority: DataTableColumnPriority.primary,
          flex: 3,
          cellBuilder: (_, item) => AppText.raw(item.name),
        ),
        DataTableColumn(
          labelKey: CollectionsKeys.code,
          priority: DataTableColumnPriority.secondary,
          flex: 2,
          cellBuilder: (_, item) => Directionality(
            textDirection: TextDirection.ltr,
            child: AppText.raw(item.code),
          ),
        ),
        DataTableColumn(
          labelKey: CollectionsKeys.startDate,
          priority: DataTableColumnPriority.hiddenOnMobile,
          flex: 2,
          cellBuilder: (_, item) => item.startDate == null
              ? AppText(CommonKeys.noValue)
              : AppText.raw(DateOnly.toApiString(item.startDate!)),
        ),
      ],
      labels: collectionsCrudLabels,
      cardBuilder: (context, item) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppLogoThumb(
            url: item.image,
            label: item.name,
            size: AppLogoSize.small,
            fallbackIcon: AppIcons.catalog,
          ),
          SizedBox(width: context.ui.spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.raw(item.name, type: AppTextType.titleSmall),
                AppText.raw(item.code),
                item.startDate == null
                    ? AppText(CommonKeys.noValue)
                    : AppText.raw(DateOnly.toApiString(item.startDate!)),
                AppBadge(
                  label: item.isActive
                      ? CollectionsKeys.active
                      : CollectionsKeys.inactive,
                  tone: item.isActive
                      ? AppBadgeTone.success
                      : AppBadgeTone.neutral,
                  size: AppBadgeSize.small,
                ),
              ],
            ),
          ),
        ],
      ),
      gridBuilder: (_, item) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppLogoThumb(
            url: item.image,
            label: item.name,
            size: AppLogoSize.small,
            fallbackIcon: AppIcons.catalog,
          ),
          AppText.raw(item.name, type: AppTextType.titleSmall),
          AppText.raw(item.code),
          item.startDate == null
              ? AppText(CommonKeys.noValue)
              : AppText.raw(DateOnly.toApiString(item.startDate!)),
          AppBadge(
            label: item.isActive
                ? CollectionsKeys.active
                : CollectionsKeys.inactive,
            tone: item.isActive ? AppBadgeTone.success : AppBadgeTone.neutral,
            size: AppBadgeSize.small,
          ),
        ],
      ),
      statusColumn: CrudStatusColumnConfig<CatalogCollection>(
        labelKey: CollectionsKeys.status,
        isActive: (item) => item.isActive,
        badgeBuilder: (_, item) => AppBadge(
          label: item.isActive
              ? CollectionsKeys.active
              : CollectionsKeys.inactive,
          tone: item.isActive ? AppBadgeTone.success : AppBadgeTone.neutral,
          size: AppBadgeSize.small,
        ),
      ),
      icon: AppIcons.catalog,
      emptyTitleKey: CollectionsKeys.empty,
      emptyDescriptionKey: CollectionsKeys.emptyDescription,
      noResultsTitleKey: CollectionsKeys.noResults,
      noResultsDescriptionKey: CollectionsKeys.noResultsDescription,
    );
