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

/// The category tree is loaded once and never paged. Search/status projections
/// are flat and use 25 rows per page. The tree cap is shared with the repository.
class CategoryListQuery extends Equatable
    implements PagedQuery<CategoryListQuery> {
  const CategoryListQuery({
    this.search = '',
    this.status = CategoryStatusFilter.all,
    this.expandedIds,
    this.page = 1,
    this.flatPageSize = 25,
  });

  static const treePageSize = 2000;

  @override
  final String search;
  final CategoryStatusFilter status;

  /// Open parents; null means the default (roots open).
  final Set<int>? expandedIds;
  @override
  final int page;

  /// Flat search/filter result page size. The unfiltered tree uses [treePageSize].
  final int flatPageSize;

  @override
  int get pageSize => hasActiveFilters ? flatPageSize : treePageSize;

  /// A search or status filter turns the tree into a flat result list.
  @override
  bool get hasActiveFilters =>
      search.trim().isNotEmpty || status != CategoryStatusFilter.all;

  @override
  CategoryListQuery withSearch(String value) => _copy(search: value);

  @override
  CategoryListQuery withPage(int value) => value == page
      ? this
      : CategoryListQuery(
          search: search,
          status: status,
          expandedIds: expandedIds,
          page: value,
          flatPageSize: flatPageSize,
        );

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
    flatPageSize: flatPageSize,
  );

  CategoryListQuery _copy({String? search, CategoryStatusFilter? status}) =>
      CategoryListQuery(
        search: search ?? this.search,
        status: status ?? this.status,
        expandedIds: expandedIds,
        page: 1,
        flatPageSize: flatPageSize,
      );

  @override
  List<Object?> get props => [search, status, expandedIds, page, flatPageSize];
}
