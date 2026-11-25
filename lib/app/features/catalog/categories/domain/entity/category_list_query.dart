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

/// The category list is a tree loaded once and shaped locally, so there is no
/// sort. The tree itself is not paged; a search or status filter turns it into
/// a flat result list, and only that list is paged (spec §10).
class CategoryListQuery extends Equatable
    implements PagedQuery<CategoryListQuery> {
  const CategoryListQuery({
    this.search = '',
    this.status = CategoryStatusFilter.all,
    this.expandedIds,
    this.page = 1,
    this.pageSize = 25,
  });

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

  @override
  CategoryListQuery withPage(int value) => value == page
      ? this
      : CategoryListQuery(
          search: search,
          status: status,
          expandedIds: expandedIds,
          page: value,
          pageSize: pageSize,
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
