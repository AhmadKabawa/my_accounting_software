import 'package:equatable/equatable.dart';
import 'package:accounting_software/app/core/foundation/types/paged_query.dart';

enum CategoryStatusFilter {
  all,
  active,
  inactive;

  bool? get isActive => switch (this) {
    CategoryStatusFilter.all => null,
    CategoryStatusFilter.active => true,
    CategoryStatusFilter.inactive => false,
  };
}

enum CategoryLevelFilter { all, roots, leaves }

enum CategoryUsageFilter { all, withProducts, withoutProducts }

enum CategorySortField {
  name,
  sortOrder,
  productCount;

  static CategorySortField? tryParse(String value) => switch (value) {
    'name' => CategorySortField.name,
    'sortOrder' => CategorySortField.sortOrder,
    'productCount' => CategorySortField.productCount,
    _ => null,
  };
}

/// The complete tree is cached; all filters and flat sorting are local.
class CategoryListQuery extends Equatable
    implements PagedQuery<CategoryListQuery> {
  const CategoryListQuery({
    this.search = '',
    this.status = CategoryStatusFilter.all,
    this.level = CategoryLevelFilter.all,
    this.usage = CategoryUsageFilter.all,
    this.sortField = CategorySortField.sortOrder,
    this.sortAscending = true,
    this.expandedIds,
    this.page = 1,
    this.flatPageSize = 25,
  });

  static const treePageSize = 2000;

  @override
  final String search;
  final CategoryStatusFilter status;
  final CategoryLevelFilter level;
  final CategoryUsageFilter usage;
  final CategorySortField sortField;
  final bool sortAscending;
  final Set<int>? expandedIds;
  @override
  final int page;
  final int flatPageSize;

  @override
  int get pageSize => hasActiveFilters ? flatPageSize : treePageSize;

  @override
  bool get hasActiveFilters =>
      search.trim().isNotEmpty ||
      status != CategoryStatusFilter.all ||
      level != CategoryLevelFilter.all ||
      usage != CategoryUsageFilter.all;

  @override
  CategoryListQuery withSearch(String value) => _copy(search: value);

  @override
  CategoryListQuery withPage(int value) =>
      value == page ? this : _copy(page: value);

  @override
  CategoryListQuery cleared() =>
      CategoryListQuery(expandedIds: expandedIds, flatPageSize: flatPageSize);

  CategoryListQuery withStatus(CategoryStatusFilter value) =>
      status == value ? this : _copy(status: value);

  CategoryListQuery withLevel(CategoryLevelFilter value) =>
      level == value && usage == CategoryUsageFilter.all
      ? this
      : _copy(level: value, usage: CategoryUsageFilter.all);

  CategoryListQuery withUsage(CategoryUsageFilter value) =>
      usage == value && level == CategoryLevelFilter.all
      ? this
      : _copy(usage: value, level: CategoryLevelFilter.all);

  CategoryListQuery withSort({
    required CategorySortField field,
    required bool ascending,
  }) => sortField == field && sortAscending == ascending
      ? this
      : _copy(sortField: field, sortAscending: ascending);

  CategoryListQuery withExpanded(Set<int>? ids) => CategoryListQuery(
    search: search,
    status: status,
    level: level,
    usage: usage,
    sortField: sortField,
    sortAscending: sortAscending,
    expandedIds: ids,
    page: page,
    flatPageSize: flatPageSize,
  );

  CategoryListQuery _copy({
    String? search,
    CategoryStatusFilter? status,
    CategoryLevelFilter? level,
    CategoryUsageFilter? usage,
    CategorySortField? sortField,
    bool? sortAscending,
    int? page,
  }) => CategoryListQuery(
    search: search ?? this.search,
    status: status ?? this.status,
    level: level ?? this.level,
    usage: usage ?? this.usage,
    sortField: sortField ?? this.sortField,
    sortAscending: sortAscending ?? this.sortAscending,
    expandedIds: expandedIds,
    page: page ?? 1,
    flatPageSize: flatPageSize,
  );

  @override
  List<Object?> get props => [
    search,
    status,
    level,
    usage,
    sortField,
    sortAscending,
    expandedIds,
    page,
    flatPageSize,
  ];
}
