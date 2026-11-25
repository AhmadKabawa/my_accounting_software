import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/flash_messages.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/entity/category.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/entity/category_list_query.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/entity/category_node.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/failures/category_failures.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/usecase/delete_category_use_case.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/usecase/get_categories_use_case.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/usecase/set_category_active_use_case.dart';
import 'package:accounting_software/app/features/catalog/categories/presentation/cubit/categories_list/categories_list_cubit.dart';

import '../support/fake_categories_repository.dart';

Category _category(
  int id, {
  int? parentId,
  bool active = true,
  int? products = 0,
}) => Category(
  id: id,
  parentId: parentId,
  name: 'Category $id',
  slug: 'category-$id',
  sortOrder: id,
  isActive: active,
  productCount: products,
);

CategoriesListCubit _cubit(FakeCategoriesRepository repository) =>
    CategoriesListCubit(
      getCategories: GetCategoriesUseCase(repository),
      setCategoryActive: SetCategoryActiveUseCase(repository),
      deleteCategory: DeleteCategoryUseCase(repository),
      flashMessages: FlashMessages(),
    );

void main() {
  test('tree expand and collapse are local projections without network calls', () async {
    final repository = FakeCategoriesRepository(
      categories: [
        _category(1),
        _category(2, parentId: 1),
        _category(3, parentId: 2),
      ],
    );
    final cubit = _cubit(repository);
    await cubit.load();
    expect(repository.getAllCalls, 1);
    expect(cubit.state.query.pageSize, CategoryListQuery.treePageSize);
    expect(cubit.state.result!.totalCount, 2);
    expect(cubit.state.result!.items.map((row) => row.id), [1, 2]);

    cubit.selection.selectPage([1]);
    cubit.toggleExpanded(2);
    expect(cubit.state.result!.items.map((row) => row.id), [1, 2, 3]);
    cubit.collapseAll();
    expect(cubit.state.result!.items.map((row) => row.id), [1]);
    expect(cubit.selection.state, isEmpty);
    cubit.expandAll();
    expect(cubit.state.result!.items.map((row) => row.id), [1, 2, 3]);
    expect(repository.getAllCalls, 1);
    await cubit.close();
  });

  test('status filtering and page changes are local and flat', () async {
    final repository = FakeCategoriesRepository(
      categories: List.generate(30, (index) => _category(index + 1)),
    );
    final cubit = _cubit(repository);
    await cubit.load();

    await cubit.setStatus(CategoryStatusFilter.active);
    expect(cubit.state.query.pageSize, 25);
    expect(cubit.state.result!.items, hasLength(25));
    expect(cubit.state.result!.items.every((row) => row.flat), isTrue);

    await cubit.setPage(2);
    expect(cubit.state.query.page, 2);
    expect(cubit.state.result!.items, hasLength(5));
    expect(repository.getAllCalls, 1);
    await cubit.close();
  });

  test('delete guard rejects parents, used leaves and unknown product counts', () async {
    final repository = FakeCategoriesRepository(
      categories: [
        _category(1),
        _category(2, parentId: 1),
        _category(3, products: 2),
        _category(4, products: null),
        _category(5, products: 0),
      ],
    );
    final cubit = _cubit(repository);
    await cubit.load();

    final rows = cubit.state.result!.items;
    expect(cubit.beforeDelete(rows.firstWhere((row) => row.id == 1)),
        isA<CategoryInUseFailure>());
    expect(cubit.beforeDelete(rows.firstWhere((row) => row.id == 3)),
        isA<CategoryInUseFailure>());
    expect(cubit.beforeDelete(rows.firstWhere((row) => row.id == 4)),
        isA<CategoryUsageUnknownFailure>());
    expect(cubit.beforeDelete(rows.firstWhere((row) => row.id == 5)), isNull);
    expect(repository.deletedIds, isEmpty);
    await cubit.close();
  });

  test('successful status mutation invalidates and reloads cached tree', () async {
    final repository = FakeCategoriesRepository(categories: [_category(1)]);
    final cubit = _cubit(repository);
    await cubit.load();
    expect(cubit.tree, isNotNull);

    final result = await cubit.deactivate(1);

    expect(result, const Right(unit));
    expect(repository.statusUpdates, [(1, false)]);
    expect(repository.getAllCalls, 2);
    expect(cubit.tree, isNotNull);
    await cubit.close();
  });

  test('saving a category invalidates the cached tree before reload', () async {
    final repository = FakeCategoriesRepository(categories: [_category(1)]);
    final cubit = _cubit(repository);
    await cubit.load();

    await cubit.onCategorySaved(isNew: true);

    expect(repository.getAllCalls, 2);
    expect(cubit.tree, isNotNull);
    await cubit.close();
  });

  test('failed status mutation preserves cached tree and does not reload', () async {
    final repository = FakeCategoriesRepository(categories: [_category(1)])
      ..mutationResult = const Left(CategoryInUseFailure());
    final cubit = _cubit(repository);
    await cubit.load();
    final cached = cubit.tree;

    final result = await cubit.deactivate(1);

    expect(result.isLeft(), isTrue);
    expect(cubit.tree, same(cached));
    expect(repository.getAllCalls, 1);
    await cubit.close();
  });
}
