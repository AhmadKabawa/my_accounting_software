import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/localization/keys/common_keys.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_details_panel/app_details_panel.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_image/app_image.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_row_actions/app_row_actions.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/entity/category_node.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/entity/category_tree.dart';
import 'package:accounting_software/app/features/catalog/categories/presentation/localization/categories_keys.dart';
import 'package:accounting_software/app/features/catalog/categories/presentation/widgets/category_status_badge.dart';

class CategoryDetailsPanel extends StatelessWidget {
  const CategoryDetailsPanel({
    super.key,
    required this.node,
    required this.tree,
    required this.onClose,
    required this.onSelectChild,
    required this.width,
    this.canManage = false,
    this.onEdit,
    this.onAddChild,
    this.onToggleStatus,
    this.onDuplicate,
    this.onDelete,
  });

  final CategoryNode node;
  final CategoryTree tree;
  final VoidCallback onClose;
  final ValueChanged<int> onSelectChild;
  final double width;
  final bool canManage;
  final VoidCallback? onEdit;
  final VoidCallback? onAddChild;
  final VoidCallback? onToggleStatus;
  final VoidCallback? onDuplicate;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final category = node.category;
    final children = tree.childrenOf(node.id);
    final visibleNodes = tree.visible(expandedIds: tree.parentIds);
    final path = [...node.ancestors, category.name].join(' › ');
    return AppDetailsPanel(
      titleKey: CategoriesKeys.details,
      closeLabelKey: CategoriesKeys.closeDetails,
      onClose: onClose,
      width: width,
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height - context.ui.spacing.xxxl * 3,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (category.image?.trim().isNotEmpty == true)
                    AppImage.network(
                      category.image!,
                      width: AppComponentSize.avatarLarge.of(context),
                      height: AppComponentSize.avatarLarge.of(context),
                      errorWidget: const AppIcon(AppIcons.brokenImage),
                    )
                  else
                    const AppIcon(AppIcons.catalog),
                  context.ui.spacing.gap(AppSpacing.sm, axis: Axis.horizontal),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText.raw(
                          category.name,
                          type: AppTextType.titleMedium,
                        ),
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: AppText.raw(
                            category.slug,
                            type: AppTextType.bodySmall,
                            color: context.ui.theme.colors.onSurfaceVariant,
                          ),
                        ),
                        CategoryStatusBadge(category),
                        if (node.underInactiveAncestor)
                          AppText(
                            CategoriesKeys.underInactiveParent,
                            type: AppTextType.bodySmall,
                            color: context.ui.theme.colors.onSurfaceVariant,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              context.ui.spacing.gap(AppSpacing.md),
              _line(context, CategoriesKeys.path, path),
              _line(
                context,
                CategoriesKeys.description,
                category.description?.trim().isNotEmpty == true
                    ? category.description!
                    : CommonKeys.noValue.tr(context: context),
              ),
              _line(
                context,
                CategoriesKeys.subcategories,
                node.childCount.toString(),
              ),
              _line(
                context,
                CategoriesKeys.descendantCount,
                tree.descendantIds(node.id).length.toString(),
              ),
              _line(
                context,
                CategoriesKeys.products,
                category.productCount?.toString() ??
                    CommonKeys.noValue.tr(context: context),
              ),
              _line(
                context,
                CategoriesKeys.sortOrder,
                category.sortOrder.toString(),
              ),
              if (children.isNotEmpty) ...[
                context.ui.spacing.gap(AppSpacing.md),
                AppText(
                  CategoriesKeys.directChildren,
                  type: AppTextType.titleSmall,
                ),
                for (final child in children)
                  Builder(
                    builder: (context) {
                      final childNode = visibleNodes.firstWhere(
                        (candidate) => candidate.id == child.id,
                      );
                      return AppButton.raw(
                        child.name,
                        onPressed: () => onSelectChild(childNode.id),
                        variant: AppButtonVariant.text,
                        size: AppButtonSize.small,
                        icon: AppIcons.chevronEnd,
                        expand: true,
                      );
                    },
                  ),
              ],
              if (canManage) ...[
                context.ui.spacing.gap(AppSpacing.md),
                AppRowActions(
                  primary: [
                    AppRowAction(
                      icon: AppIcons.edit,
                      labelKey: CategoriesKeys.edit,
                      onPressed: onEdit,
                    ),
                    AppRowAction(
                      icon: AppIcons.add,
                      labelKey: CategoriesKeys.addChild,
                      onPressed: onAddChild,
                    ),
                  ],
                  overflow: [
                    AppRowAction(
                      icon: category.isActive
                          ? AppIcons.block
                          : AppIcons.restore,
                      labelKey: category.isActive
                          ? CategoriesKeys.deactivate
                          : CategoriesKeys.activate,
                      onPressed: onToggleStatus,
                    ),
                    AppRowAction(
                      icon: AppIcons.copy,
                      labelKey: CategoriesKeys.duplicate,
                      onPressed: onDuplicate,
                    ),
                    if (node.canDelete)
                      AppRowAction(
                        icon: AppIcons.delete,
                        labelKey: CategoriesKeys.delete,
                        onPressed: onDelete,
                        destructive: true,
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _line(BuildContext context, AppKey label, String value) => Padding(
    padding: EdgeInsets.only(bottom: context.ui.spacing.sm),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: AppComponentSize.tableColumnMin.of(context),
          child: AppText(
            label,
            type: AppTextType.bodySmall,
            color: context.ui.theme.colors.onSurfaceVariant,
          ),
        ),
        Expanded(child: AppText.raw(value)),
      ],
    ),
  );
}
