import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_button.dart';
import 'package:accounting_software/app/features/catalog/categories/presentation/localization/categories_keys.dart';

class CategoriesTreeToolbar extends StatelessWidget {
  const CategoriesTreeToolbar({
    super.key,
    required this.onExpandAll,
    required this.onCollapseAll,
    required this.enabled,
  });

  final VoidCallback onExpandAll;
  final VoidCallback onCollapseAll;
  final bool enabled;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: context.ui.spacing.sm,
    runSpacing: context.ui.spacing.sm,
    children: [
      AppButton(
        CategoriesKeys.expandAll,
        onPressed: enabled ? onExpandAll : null,
        icon: AppIcons.expand,
        variant: AppButtonVariant.outlined,
        size: AppButtonSize.small,
      ),
      AppButton(
        CategoriesKeys.collapseAll,
        onPressed: enabled ? onCollapseAll : null,
        icon: AppIcons.collapse,
        variant: AppButtonVariant.outlined,
        size: AppButtonSize.small,
      ),
    ],
  );
}
