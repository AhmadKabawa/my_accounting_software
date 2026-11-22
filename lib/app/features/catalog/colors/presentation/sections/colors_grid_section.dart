import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/access/permission_gate/permission_gate.dart';
import 'package:accounting_software/app/core/access/permissions.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/localization/keys/catalog_ui_keys.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_card/app_card.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_empty_state/app_empty_state.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_inline_banner/inline_banner.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_row_actions/app_row_actions.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_skeleton/app_skeleton.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/entity/catalog_color.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/entity/color_list_query.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/localization/colors_keys.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/widgets/color_card.dart';

class ColorsGridSection extends StatelessWidget {
  const ColorsGridSection({
    super.key,
    required this.query,
    required this.rows,
    required this.total,
    required this.loading,
    required this.refreshing,
    required this.failure,
    required this.onRetry,
    required this.onAdd,
    required this.onEdit,
    required this.onToggleStatus,
    required this.onDelete,
    required this.onPageChanged,
  });

  final ColorListQuery query;
  final List<CatalogColor> rows;
  final int total;
  final bool loading;
  final bool refreshing;
  final Failure? failure;
  final VoidCallback onRetry;
  final VoidCallback onAdd;
  final ValueChanged<CatalogColor> onEdit;
  final ValueChanged<CatalogColor> onToggleStatus;
  final ValueChanged<CatalogColor> onDelete;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    if (failure != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InlineBanner(
            messageKey: failure!.messageKey,
            variant: InlineBannerVariant.error,
          ),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: AppButton(
              CatalogUiKeys.retry,
              variant: AppButtonVariant.text,
              onPressed: onRetry,
            ),
          ),
        ],
      );
    }
    if (loading) return const AppSkeleton.card();
    if (rows.isEmpty) {
      final unfiltered = !query.isFiltered;
      return AppEmptyState(
        icon: AppIcons.colors,
        titleKey: unfiltered ? ColorsKeys.empty : ColorsKeys.noResults,
        descriptionKey: unfiltered
            ? ColorsKeys.emptyDescription
            : ColorsKeys.noResultsDescription,
        action: unfiltered
            ? PermissionGate(
                permission: Permissions.masterData.manage,
                child: AppButton(
                  ColorsKeys.add,
                  icon: AppIcons.add,
                  onPressed: onAdd,
                ),
              )
            : null,
      );
    }

    final pages = (total / query.pageSize).ceil();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (refreshing) const AppSkeleton.line(),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: context.ui.size.width(AppComponentSize.cardWidth),
            mainAxisExtent:
                context.ui.size.height(AppComponentSize.cardHeight) +
                context.ui.spacing.lg,
            crossAxisSpacing: context.ui.spacing.md,
            mainAxisSpacing: context.ui.spacing.md,
          ),
          itemCount: rows.length,
          itemBuilder: (context, index) {
            final color = rows[index];
            return AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: ColorCard(color, swatchSize: AppIconSize.xl),
                  ),
                  PermissionGate(
                    permission: Permissions.masterData.manage,
                    child: Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: AppRowActions(
                        primary: [
                          AppRowAction(
                            icon: AppIcons.edit,
                            labelKey: ColorsKeys.edit,
                            onPressed: () => onEdit(color),
                          ),
                          AppRowAction(
                            icon: color.isActive
                                ? AppIcons.block
                                : AppIcons.restore,
                            labelKey: color.isActive
                                ? ColorsKeys.deactivate
                                : ColorsKeys.activate,
                            iconColor: color.isActive
                                ? context.ui.theme.colors.error
                                : null,
                            onPressed: () => onToggleStatus(color),
                          ),
                        ],
                        overflow: [
                          AppRowAction(
                            icon: AppIcons.delete,
                            labelKey: ColorsKeys.delete,
                            destructive: true,
                            onPressed: () => onDelete(color),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        context.ui.spacing.gap(AppSpacing.md),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            AppButton(
              ColorsKeys.previousPage,
              variant: AppButtonVariant.outlined,
              size: AppButtonSize.small,
              onPressed: query.page > 1
                  ? () => onPageChanged(query.page - 1)
                  : null,
            ),
            context.ui.spacing.gap(AppSpacing.sm, axis: Axis.horizontal),
            AppText.raw('${query.page} / $pages'),
            context.ui.spacing.gap(AppSpacing.sm, axis: Axis.horizontal),
            AppButton(
              ColorsKeys.nextPage,
              variant: AppButtonVariant.outlined,
              size: AppButtonSize.small,
              onPressed: query.page < pages
                  ? () => onPageChanged(query.page + 1)
                  : null,
            ),
          ],
        ),
      ],
    );
  }
}
