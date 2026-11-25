import 'package:equatable/equatable.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/entity/category.dart';

/// One visible row of the category list: a [Category] plus what the tree
/// derives about it (depth, ancestors, children, expansion).
class CategoryNode extends Equatable {
  const CategoryNode({
    required this.category,
    required this.depth,
    required this.ancestors,
    required this.childCount,
    required this.activeChildCount,
    required this.expanded,
    this.flat = false,
  });

  final Category category;

  /// 0 for roots, and for every row of a flat (search/filter) result.
  final int depth;

  /// Names from the root down to the parent; empty for a root.
  final List<String> ancestors;

  /// Direct children, active or not.
  final int childCount;
  final int activeChildCount;
  final bool expanded;

  /// True when the row is part of a flat result, so its context is [ancestors].
  final bool flat;

  int get id => category.id;
  bool get hasChildren => childCount > 0;

  /// Only a leaf with no products may be deleted; anything else is deactivated.
  bool get canDelete => childCount == 0 && category.productCount == 0;

  @override
  List<Object?> get props => [
    category,
    depth,
    ancestors,
    childCount,
    activeChildCount,
    expanded,
    flat,
  ];
}
