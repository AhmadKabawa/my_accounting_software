import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_button_style.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_icon_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
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
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      AppIconButton(
        AppIcons.expand,
        tooltipKey: CategoriesKeys.expandAll,
        onPressed: enabled ? onExpandAll : null,
        size: AppButtonSize.small,
      ),
      AppIconButton(
        AppIcons.collapse,
        tooltipKey: CategoriesKeys.collapseAll,
        onPressed: enabled ? onCollapseAll : null,
        size: AppButtonSize.small,
      ),
    ],
  );
}
