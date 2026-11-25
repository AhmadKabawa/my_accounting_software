import 'package:equatable/equatable.dart';
import 'package:accounting_software/app/core/foundation/types/paged_query.dart';

enum CategoryStatusFilter {
  all,
  active,
  inactive;

  /// The `is_active` value to match, or null for no filtering.
  bool? get isActive => switch (this) {
    CategoryStatusFilter.all => null,
    CategoryStatusFilter.active => true,
    CategoryStatusFilter.inactive => false,
  };
}

/// The category list is a tree loaded once and shaped locally, so this query
/// has no sort and no real paging: [pageSize] only has to exceed the largest
/// tree the loader accepts.
class CategoryListQuery extends Equatable
    implements PagedQuery<CategoryListQuery> {
  const CategoryListQuery({
    this.search = '',
    this.status = CategoryStatusFilter.all,
    this.expandedIds,
    this.page = 1,
    this.pageSize = treePageSize,
  });

  static const treePageSize = 10000;

  @override
  final String search;
  final CategoryStatusFilter status;

  /// Open parents; null means the default (roots open).
  final Set<int>? expandedIds;
  @override
  final int page;
  @override
  final int pageSize;

  /// A search or status filter turns the tree into a flat result list.
  @override
  bool get hasActiveFilters =>
      search.trim().isNotEmpty || status != CategoryStatusFilter.all;

  @override
  CategoryListQuery withSearch(String value) => _copy(search: value);

  /// There is one page only.
  @override
  CategoryListQuery withPage(int value) => this;

  @override
  CategoryListQuery cleared() =>
      _copy(search: '', status: CategoryStatusFilter.all);

  CategoryListQuery withStatus(CategoryStatusFilter value) =>
      status == value ? this : _copy(status: value);

  CategoryListQuery withExpanded(Set<int>? ids) => CategoryListQuery(
    search: search,
    status: status,
    expandedIds: ids,
    page: page,
    pageSize: pageSize,
  );

  CategoryListQuery _copy({String? search, CategoryStatusFilter? status}) =>
      CategoryListQuery(
        search: search ?? this.search,
        status: status ?? this.status,
        expandedIds: expandedIds,
        page: 1,
        pageSize: pageSize,
      );

  @override
  List<Object?> get props => [search, status, expandedIds, page, pageSize];
}
