import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_badge/app_badge.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/entity/category.dart';
import 'package:accounting_software/app/features/catalog/categories/presentation/localization/categories_keys.dart';

class CategoryStatusBadge extends StatelessWidget {
  const CategoryStatusBadge(this.category, {super.key});

  final Category category;

  @override
  Widget build(BuildContext context) => AppBadge(
    label: category.isActive ? CategoriesKeys.active : CategoriesKeys.inactive,
    tone: category.isActive ? AppBadgeTone.success : AppBadgeTone.neutral,
    size: AppBadgeSize.small,
  );
}
