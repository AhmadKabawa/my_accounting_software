import 'package:accounting_software/app/features/catalog/categories/domain/entity/category.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/entity/category_node.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/entity/category_list_query.dart';

/// The category hierarchy built from the flat table rows. Pure Dart.
///
/// The database only forbids a category being its own parent; longer cycles
/// and parents that are missing are possible, so the tree repairs them
/// (promotes the category to a root) instead of letting rows disappear.
class CategoryTree {
  CategoryTree._(
    this._byId,
    this._children,
    this._roots,
    this._parentOf,
    this._depthOf,
  );

  factory CategoryTree(Iterable<Category> categories) {
    final byId = <int, Category>{for (final c in categories) c.id: c};
    final children = <int, List<Category>>{};
    final roots = <Category>[];
    for (final c in byId.values) {
      final parent = c.parentId;
      if (parent == null || parent == c.id || !byId.containsKey(parent)) {
        roots.add(c);
      } else {
        children.putIfAbsent(parent, () => []).add(c);
      }
    }

    final reachable = <int>{};
    void mark(Category start) {
      final stack = [start];
      while (stack.isNotEmpty) {
        final current = stack.removeLast();
        if (!reachable.add(current.id)) continue;
        stack.addAll(children[current.id] ?? const []);
      }
    }

    roots.forEach(mark);

    // Whatever no root reaches sits in a parent cycle: promote one member per
    // cycle (the first in display order) so every category stays listed.
    final ordered = byId.values.toList()..sort(_compare);
    for (final c in ordered) {
      if (reachable.contains(c.id)) continue;
      children[c.parentId]?.removeWhere((child) => child.id == c.id);
      roots.add(c);
      mark(c);
    }

    roots.sort(_compare);
    for (final list in children.values) {
      list.sort(_compare);
    }

    final parentOf = <int, int>{};
    final depthOf = <int, int>{};
    final stack = <(Category, int)>[for (final r in roots) (r, 0)];
    while (stack.isNotEmpty) {
      final (current, depth) = stack.removeLast();
      depthOf[current.id] = depth;
      for (final child in children[current.id] ?? const <Category>[]) {
        parentOf[child.id] = current.id;
        stack.add((child, depth + 1));
      }
    }
    return CategoryTree._(byId, children, roots, parentOf, depthOf);
  }

  final Map<int, Category> _byId;
  final Map<int, List<Category>> _children;
  final List<Category> _roots;
  final Map<int, int> _parentOf;
  final Map<int, int> _depthOf;

  /// Siblings order: display order, then name, then id for stability.
  static int _compare(Category a, Category b) {
    final byOrder = a.sortOrder.compareTo(b.sortOrder);
    if (byOrder != 0) return byOrder;
    final byName = a.name.toLowerCase().compareTo(b.name.toLowerCase());
    return byName != 0 ? byName : a.id.compareTo(b.id);
  }

  int get length => _byId.length;
  bool get isEmpty => _byId.isEmpty;
  int get activeCount => _byId.values.where((item) => item.isActive).length;
  int get inactiveCount => length - activeCount;
  int get rootCount => _roots.length;
  int get leafCount => _byId.keys.where((id) => childrenOf(id).isEmpty).length;

  /// Null means at least one row has an unknown product relation count.
  int? get withoutProductsCount => _byId.values.any((item) => item.productCount == null)
      ? null
      : _byId.values.where((item) => item.productCount == 0).length;

  Category? byId(int id) => _byId[id];

  /// Direct children of [id]; the roots when [id] is null.
  List<Category> childrenOf(int? id) =>
      id == null ? _roots : (_children[id] ?? const []);

  int depthOf(int id) => _depthOf[id] ?? 0;

  /// Parent ids from the root down to the direct parent of [id].
  List<int> ancestorIds(int id) {
    final ids = <int>[];
    var parent = _parentOf[id];
    while (parent != null) {
      ids.add(parent);
      parent = _parentOf[parent];
    }
    return ids.reversed.toList();
  }

  /// Names from the root down to the parent of [id]; empty for a root.
  List<String> ancestorNames(int id) {
    final names = <String>[];
    var parent = _parentOf[id];
    while (parent != null) {
      final category = _byId[parent];
      if (category == null) break;
      names.add(category.name);
      parent = _parentOf[parent];
    }
    return names.reversed.toList();
  }

  /// Every category below [id] (not [id] itself). A parent picker must
  /// exclude these, or a category could become its own ancestor.
  Set<int> descendantIds(int id) {
    final result = <int>{};
    final stack = [...childrenOf(id)];
    while (stack.isNotEmpty) {
      final current = stack.removeLast();
      if (result.add(current.id)) stack.addAll(childrenOf(current.id));
    }
    return result;
  }

  /// Ids of every category that has children.
  Set<int> get parentIds => {
    for (final entry in _children.entries)
      if (entry.value.isNotEmpty) entry.key,
  };

  /// Roots start open, so the first two levels show.
  Set<int> get defaultExpandedIds => {
    for (final root in _roots)
      if (childrenOf(root.id).isNotEmpty) root.id,
  };

  bool _hasInactiveAncestor(int id) {
    var parent = _parentOf[id];
    while (parent != null) {
      final ancestor = _byId[parent];
      if (ancestor == null) break;
      if (!ancestor.isActive) return true;
      parent = _parentOf[parent];
    }
    return false;
  }

  CategoryNode _node(
    Category category, {
    required bool expanded,
    bool flat = false,
  }) {
    final kids = childrenOf(category.id);
    return CategoryNode(
      category: category,
      depth: flat ? 0 : depthOf(category.id),
      ancestors: ancestorNames(category.id),
      childCount: kids.length,
      activeChildCount: kids.where((child) => child.isActive).length,
      expanded: expanded,
      flat: flat,
      underInactiveAncestor: _hasInactiveAncestor(category.id),
    );
  }

  /// The tree as rows, honouring which parents are open. [expandedIds] null
  /// means the default (roots open).
  List<CategoryNode> visible({Set<int>? expandedIds}) {
    final open = expandedIds ?? defaultExpandedIds;
    final rows = <CategoryNode>[];
    void add(Category category) {
      final isOpen = open.contains(category.id);
      rows.add(_node(category, expanded: isOpen));
      if (!isOpen) return;
      childrenOf(category.id).forEach(add);
    }

    _roots.forEach(add);
    return rows;
  }

  /// Filtered results are flat and retain the full ancestor path.
  List<CategoryNode> filtered({
    String search = '',
    bool? isActive,
    CategoryLevelFilter level = CategoryLevelFilter.all,
    CategoryUsageFilter usage = CategoryUsageFilter.all,
    CategorySortField sortField = CategorySortField.sortOrder,
    bool sortAscending = true,
  }) {
    final term = search.trim().toLowerCase();
    final rows = <CategoryNode>[];
    void walk(Category category) {
      final kids = childrenOf(category.id);
      final matchesText =
          term.isEmpty ||
          category.name.toLowerCase().contains(term) ||
          category.slug.toLowerCase().contains(term);
      final matchesState = isActive == null || category.isActive == isActive;
      final matchesLevel = switch (level) {
        CategoryLevelFilter.all => true,
        CategoryLevelFilter.roots => depthOf(category.id) == 0,
        CategoryLevelFilter.leaves => kids.isEmpty,
      };
      final count = category.productCount;
      final matchesUsage = switch (usage) {
        CategoryUsageFilter.all => true,
        CategoryUsageFilter.withProducts => count != null && count > 0,
        CategoryUsageFilter.withoutProducts => count == 0,
      };
      if (matchesText && matchesState && matchesLevel && matchesUsage) {
        rows.add(_node(category, expanded: false, flat: true));
      }
      kids.forEach(walk);
    }

    _roots.forEach(walk);
    int compare(CategoryNode a, CategoryNode b) {
      final ac = a.category.productCount;
      final bc = b.category.productCount;
      if (sortField == CategorySortField.productCount && (ac == null) != (bc == null)) {
        return ac == null ? 1 : -1;
      }
      final result = switch (sortField) {
        CategorySortField.name => a.category.name.toLowerCase().compareTo(
          b.category.name.toLowerCase(),
        ),
        CategorySortField.sortOrder => a.category.sortOrder.compareTo(
          b.category.sortOrder,
        ),
        CategorySortField.productCount => (ac ?? 0).compareTo(bc ?? 0),
      };
      final ordered = sortAscending ? result : -result;
      return ordered != 0 ? ordered : _compare(a.category, b.category);
    }

    rows.sort(compare);
    return rows;
  }
}
