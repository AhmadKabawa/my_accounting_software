import 'dart:math' as math;

import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/base/use_case.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/state_management/paged_list/paged_list_cubit.dart';
import 'package:accounting_software/app/core/presentation/state_management/paged_list/paged_list_state.dart';
import 'package:accounting_software/app/core/presentation/state_management/paged_list/paged_result.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/entity/category_list_query.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/entity/category_node.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/entity/category_tree.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/failures/category_failures.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/usecase/delete_category_use_case.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/usecase/get_categories_use_case.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/usecase/set_category_active_use_case.dart';
import 'package:accounting_software/app/features/catalog/categories/presentation/cubit/categories_list/categories_list_effect.dart';
import 'package:accounting_software/app/features/catalog/categories/presentation/localization/categories_keys.dart';

/// Lists the category tree through the shared CRUD engine.
///
/// The whole tree is loaded once and cached ([_tree]); the visible rows are a
/// flat projection of it. Opening/closing branches, searching and filtering
/// never touch the network. Every successful mutation drops the cache so the
/// next load reads fresh data (counts and parents change under a mutation).
class CategoriesListCubit
    extends
        PagedListCubit<CategoryNode, CategoryListQuery, CategoriesListEffect> {
  CategoriesListCubit({
    required GetCategoriesUseCase getCategories,
    required SetCategoryActiveUseCase setCategoryActive,
    required DeleteCategoryUseCase deleteCategory,
    required super.flashMessages,
  }) : _getCategories = getCategories,
       _setCategoryActive = setCategoryActive,
       _deleteCategory = deleteCategory,
       super(initialQuery: const CategoryListQuery());

  final GetCategoriesUseCase _getCategories;
  final SetCategoryActiveUseCase _setCategoryActive;
  final DeleteCategoryUseCase _deleteCategory;

  CategoryTree? _tree;

  /// The loaded tree, for the editor's parent picker. Null before first load.
  CategoryTree? get tree => _tree;

  @override
  Future<Either<Failure, PagedResult<CategoryNode>>> fetch(
    CategoryListQuery query,
  ) async {
    var tree = _tree;
    if (tree == null) {
      final response = await _getCategories(NoParams());
      final failure = response.fold<Failure?>((f) => f, (_) => null);
      if (failure != null) return Left(failure);
      tree = CategoryTree(response.getOrElse(() => const []));
      _tree = tree;
    }
    return Right(_project(tree, query));
  }

  PagedResult<CategoryNode> _project(
    CategoryTree tree,
    CategoryListQuery query,
  ) {
    if (!query.hasActiveFilters) {
      final rows = tree.visible(expandedIds: query.expandedIds);
      return PagedResult(
        items: rows,
        totalCount: tree.length,
        currentPage: 1,
        totalPages: 1,
      );
    }
    final rows = tree.filtered(
      search: query.search,
      isActive: query.status.isActive,
    );
    final pages = math.max(1, (rows.length / query.pageSize).ceil());
    final page = query.page.clamp(1, pages);
    final start = (page - 1) * query.pageSize;
    return PagedResult(
      items: rows.skip(start).take(query.pageSize).toList(),
      totalCount: rows.length,
      currentPage: page,
      totalPages: pages,
    );
  }

  /// Re-projects the cached tree without a network call or a loading flash.
  void _reproject(CategoryListQuery query) {
    final tree = _tree;
    if (tree == null) return;
    selection.clear();
    emit(
      state.copyWith(
        query: query,
        result: _project(tree, query),
        status: PagedListStatus.ready,
        clearFailure: true,
      ),
    );
  }

  Future<Either<Failure, Unit>> _invalidating(
    Future<Either<Failure, Unit>> Function() action,
  ) async {
    final response = await action();
    if (response.isRight()) _tree = null;
    return response;
  }

  @override
  Failure? beforeDelete(CategoryNode item) =>
      item.canDelete ? null : const CategoryInUseFailure();

  @override
  Future<Either<Failure, Unit>> deleteItem(CategoryNode item) =>
      _invalidating(() => _deleteCategory(item.category.id));

  @override
  AppKey get deletedMessageKey => CategoriesKeys.deleted;

  @override
  CategoriesListEffect buildMutationEffect(PagedMutationKind kind) =>
      CategoriesMutatedEffect(switch (kind) {
        PagedMutationKind.created => CategoriesMutationKind.created,
        PagedMutationKind.updated => CategoriesMutationKind.updated,
        PagedMutationKind.statusChanged => CategoriesMutationKind.statusChanged,
        PagedMutationKind.deleted => CategoriesMutationKind.deleted,
      });

  // The shared base only reloads; a local page change needs no network.
  @override
  Future<void> setPage(int page) async {
    if (page < 1 || page == state.query.page) return;
    _reproject(state.query.withPage(page));
  }

  Future<void> setStatus(CategoryStatusFilter status) async {
    if (state.query.status == status) return;
    _reproject(state.query.withStatus(status));
  }

  /// Opens or closes one branch.
  void toggleExpanded(int id) {
    final tree = _tree;
    if (tree == null) return;
    final open = {...(state.query.expandedIds ?? tree.defaultExpandedIds)};
    if (!open.remove(id)) open.add(id);
    _reproject(state.query.withExpanded(open));
  }

  void expandAll() {
    final tree = _tree;
    if (tree == null) return;
    _reproject(state.query.withExpanded(tree.parentIds));
  }

  void collapseAll() => _reproject(state.query.withExpanded(const {}));

  Future<Either<Failure, Unit>> activate(int id) => _setActive(id, true);

  Future<Either<Failure, Unit>> deactivate(int id) => _setActive(id, false);

  Future<Either<Failure, Unit>> _setActive(int id, bool isActive) =>
      runMutation(
        () => _invalidating(
          () => _setCategoryActive(
            SetCategoryActiveParams(id: id, isActive: isActive),
          ),
        ),
        kind: PagedMutationKind.statusChanged,
        successMessage: CategoriesKeys.statusUpdated,
        flashFailure: true,
        rowId: id,
      );

  Future<void> onCategorySaved({required bool isNew}) {
    _tree = null;
    return reloadAfterMutation(
      isNew ? PagedMutationKind.created : PagedMutationKind.updated,
    );
  }
}
