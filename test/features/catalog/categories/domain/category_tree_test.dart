import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/entity/category.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/entity/category_tree.dart';

Category _category(
  int id, {
  int? parentId,
  String? name,
  String? slug,
  int sortOrder = 0,
  bool active = true,
  int? products = 0,
}) => Category(
  id: id,
  parentId: parentId,
  name: name ?? 'Category $id',
  slug: slug ?? 'category-$id',
  sortOrder: sortOrder,
  isActive: active,
  productCount: products,
);

void main() {
  test('builds a tree from flat rows and orders siblings deterministically', () {
    final tree = CategoryTree([
      _category(3, parentId: 1, sortOrder: 2),
      _category(2, parentId: 1, sortOrder: 1),
      _category(1),
      _category(4),
    ]);

    expect(tree.length, 4);
    expect(tree.childrenOf(null).map((item) => item.id), [1, 4]);
    expect(tree.childrenOf(1).map((item) => item.id), [2, 3]);
    expect(tree.depthOf(3), 1);
  });

  test('derives depth, ancestor path, descendants and direct child counts', () {
    final tree = CategoryTree([
      _category(1, name: 'Shoes'),
      _category(2, parentId: 1, name: 'Sport'),
      _category(3, parentId: 2, name: 'Running'),
      _category(4, parentId: 1, active: false),
    ]);

    expect(tree.depthOf(3), 2);
    expect(tree.ancestorNames(3), ['Shoes', 'Sport']);
    expect(tree.descendantIds(1), {2, 3, 4});
    expect(tree.parentIds, {1, 2});
    expect(tree.childrenOf(1), hasLength(2));
  });

  test('default expansion shows roots and their first-level children', () {
    final tree = CategoryTree([
      _category(1),
      _category(2, parentId: 1),
      _category(3, parentId: 2),
      _category(4),
    ]);

    expect(tree.defaultExpandedIds, {1});
    final rows = tree.visible();
    expect(rows.map((row) => row.id), [1, 2, 4]);
    expect(rows.map((row) => row.depth), [0, 1, 0]);
    expect(rows.first.expanded, isTrue);
    expect(rows[1].expanded, isFalse);
  });

  test('visible respects explicit expanded ids', () {
    final tree = CategoryTree([
      _category(1),
      _category(2, parentId: 1),
      _category(3, parentId: 2),
    ]);

    expect(
      tree.visible(expandedIds: {1, 2}).map((row) => row.id),
      [1, 2, 3],
    );
    expect(tree.visible(expandedIds: {}).map((row) => row.id), [1]);
  });

  test('filtered results are flat and preserve ancestor path', () {
    final tree = CategoryTree([
      _category(1, name: 'Shoes'),
      _category(2, parentId: 1, name: 'Sport'),
      _category(3, parentId: 2, name: 'Running', slug: 'running-shoes'),
      _category(4, parentId: 1, name: 'Formal', active: false),
    ]);

    final bySearch = tree.filtered(search: 'running');
    expect(bySearch.map((row) => row.id), [3]);
    expect(bySearch.single.flat, isTrue);
    expect(bySearch.single.depth, 0);
    expect(bySearch.single.ancestors, ['Shoes', 'Sport']);

    final inactive = tree.filtered(isActive: false);
    expect(inactive.map((row) => row.id), [4]);
  });

  test('promotes orphan rows and repairs cycles without losing categories', () {
    final tree = CategoryTree([
      _category(1, parentId: 2),
      _category(2, parentId: 1),
      _category(3, parentId: 999),
    ]);

    final rows = tree.visible(expandedIds: tree.parentIds);
    expect(rows.map((row) => row.id).toSet(), {1, 2, 3});
    expect(tree.length, 3);
    expect(tree.childrenOf(null).map((item) => item.id), contains(3));
    expect(tree.depthOf(1), 0);
  });

  test('same-order names and ids provide stable sibling ordering', () {
    final tree = CategoryTree([
      _category(3, parentId: 1, name: 'Beta'),
      _category(2, parentId: 1, name: 'alpha'),
      _category(4, parentId: 1, name: 'Alpha'),
      _category(1),
    ]);

    expect(tree.childrenOf(1).map((item) => item.id), [2, 4, 3]);
  });
}
