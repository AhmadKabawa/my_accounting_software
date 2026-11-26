import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_badge/app_badge.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_button_style.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_icon_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_image/app_image.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/entity/category_node.dart';
import 'package:accounting_software/app/features/catalog/categories/presentation/localization/categories_keys.dart';

class CategoryIdentity extends StatelessWidget {
  const CategoryIdentity({
    super.key,
    required this.node,
    this.onToggle,
    this.showPathForDeep = false,
    this.showFullPath = false,
  });

  final CategoryNode node;
  final VoidCallback? onToggle;
  final bool showPathForDeep;
  final bool showFullPath;

  @override
  Widget build(BuildContext context) {
    final category = node.category;
    final showPath =
        node.flat || showFullPath || (showPathForDeep && node.depth > 4);
    final path = [...node.ancestors, category.name].join(' › ');
    final badge = AppBadge(
      label: CategoriesKeys.childrenCount,
      labelArgs: {'count': node.childCount.toString()},
      size: AppBadgeSize.small,
      tone: AppBadgeTone.neutral,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact =
            constraints.hasBoundedWidth &&
            constraints.maxWidth <=
                context.ui.size.width(AppComponentSize.tableColumnPrimaryMin);
        final indent = showPath
            ? 0.0
            : context.ui.spacing.lg * node.depth.clamp(0, 4).toDouble();
        final secondary = showPath
            ? AppText.raw(
                path,
                type: AppTextType.bodySmall,
                color: context.ui.theme.colors.onSurfaceVariant,
                maxLines: 1,
              )
            : Directionality(
                textDirection: TextDirection.ltr,
                child: AppText.raw(
                  category.slug,
                  type: AppTextType.bodySmall,
                  color: context.ui.theme.colors.onSurfaceVariant,
                  maxLines: 1,
                ),
              );

        return Padding(
          padding: EdgeInsetsDirectional.only(start: indent),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (node.hasChildren)
                Semantics(
                  expanded: node.expanded,
                  button: true,
                  child: AppIconButton(
                    node.expanded ? AppIcons.collapse : AppIcons.expand,
                    tooltipKey: node.expanded
                        ? CategoriesKeys.collapseRow
                        : CategoriesKeys.expandRow,
                    onPressed: onToggle,
                    size: AppButtonSize.small,
                  ),
                )
              else
                SizedBox(width: context.ui.spacing.xl),
              if (category.image != null && category.image!.trim().isNotEmpty)
                AppImage.network(
                  category.image!,
                  width: context.ui.spacing.xl,
                  height: context.ui.spacing.xl,
                  shape: AppImageShape.rounded,
                  borderRadius: context.ui.spacing.xs,
                  errorWidget: const AppIcon(AppIcons.brokenImage),
                )
              else
                const AppIcon(AppIcons.catalog, tone: AppIconTone.neutral),
              context.ui.spacing.gap(AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.raw(category.name, type: AppTextType.titleSmall),
                    Row(
                      children: [
                        Expanded(child: secondary),
                        if (compact && node.underInactiveAncestor)
                          AppBadge(
                            label: CategoriesKeys.underInactiveParent,
                            size: AppBadgeSize.small,
                            tone: AppBadgeTone.neutral,
                          )
                        else if (compact && node.childCount > 0)
                          badge,
                        if (!compact && node.underInactiveAncestor) ...[
                          context.ui.spacing.gap(
                            AppSpacing.xs,
                            axis: Axis.horizontal,
                          ),
                          AppBadge(
                            label: CategoriesKeys.underInactiveParent,
                            size: AppBadgeSize.small,
                            tone: AppBadgeTone.neutral,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              if (!compact && node.childCount > 0) badge,
            ],
          ),
        );
      },
    );
  }
}
