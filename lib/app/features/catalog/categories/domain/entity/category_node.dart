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
    this.underInactiveAncestor = false,
  });

  final Category category;
  final int depth;
  final List<String> ancestors;
  final int childCount;
  final int activeChildCount;
  final bool expanded;
  final bool flat;
  final bool underInactiveAncestor;

  int get id => category.id;
  bool get hasChildren => childCount > 0;

  /// Unknown embedded counts are conservative: only a known zero is deletable.
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
    underInactiveAncestor,
  ];
}
