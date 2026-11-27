import 'package:accounting_software/app/features/catalog/categories/domain/entity/category_tree.dart';

bool categoryHasSiblingNameConflict({
  required CategoryTree? tree,
  required int? parentId,
  required int? categoryId,
  required String name,
}) {
  final normalized = name.trim().toLowerCase();
  if (normalized.isEmpty) return false;
  return tree?.childrenOf(parentId).any(
        (item) =>
            item.id != categoryId &&
            item.name.trim().toLowerCase() == normalized,
      ) ??
      false;
}
