import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_row_actions/app_row_actions.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/entity/category_node.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/entity/category_tree.dart';
import 'package:accounting_software/app/features/catalog/categories/presentation/dialogs/category_editor_launcher.dart';
import 'package:accounting_software/app/features/catalog/categories/presentation/localization/categories_keys.dart';

List<AppRowAction> buildCategoryExtraRowActions({
  required BuildContext context,
  required CategoryNode node,
  required CategoryTree? tree,
  required VoidCallback onSaved,
}) => [
  AppRowAction(
    icon: AppIcons.add,
    labelKey: CategoriesKeys.addChild,
    onPressed: tree == null
        ? null
        : () {
            showCategoryEditor(
              context,
              tree: tree,
              initialParentId: node.id,
            ).then((saved) {
              if (saved == true && context.mounted) onSaved();
            });
          },
  ),
];
