import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/entity/category_node.dart';
import 'package:accounting_software/app/features/catalog/categories/presentation/widgets/category_identity.dart';
import 'package:accounting_software/app/features/catalog/categories/presentation/widgets/category_status_badge.dart';

class CategoryCard extends StatelessWidget {
  const CategoryCard({super.key, required this.node, this.onToggle});

  final CategoryNode node;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      CategoryIdentity(node: node, onToggle: onToggle, showPathForDeep: true),
      context.ui.spacing.gap(AppSpacing.sm),
      Align(
        alignment: AlignmentDirectional.centerStart,
        child: CategoryStatusBadge(node.category),
      ),
    ],
  );
}
