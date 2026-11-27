import 'package:equatable/equatable.dart';
import 'package:accounting_software/app/core/foundation/types/paged_query.dart';
import 'package:accounting_software/app/features/catalog/size_systems/shared/domain/size_status_filter.dart';

enum CatalogSizeSortField {
  /// sort_order, then numeric_value, then id (the group's natural order).
  order('sort_order'),
  name('name'),
  code('code'),
  value('numeric_value');

  const CatalogSizeSortField(this.column);
  final String column;

  static CatalogSizeSortField? tryParse(String? name) {
    for (final value in values) {
      if (value.name == name) return value;
    }
    return null;
  }
}

class CatalogSizeListQuery extends Equatable
    implements PagedQuery<CatalogSizeListQuery> {
  const CatalogSizeListQuery({
    required this.sizeGroupId,
    this.search = '',
    this.status = SizeStatusFilter.all,
    this.sortField = CatalogSizeSortField.order,
    this.sortAscending = true,
    this.page = 1,
    this.pageSize = 50,
  });

  /// The parent group; every request is scoped to it (D-SZ-2).
  final int sizeGroupId;
  @override
  final String search;
  final SizeStatusFilter status;
  final CatalogSizeSortField sortField;
  final bool sortAscending;
  @override
  final int page;
  @override
  final int pageSize;

  @override
  bool get hasActiveFilters =>
      search.isNotEmpty || status != SizeStatusFilter.all;

  @override
  CatalogSizeListQuery withSearch(String value) =>
      copyWith(search: value, page: 1);

  @override
  CatalogSizeListQuery withPage(int value) => copyWith(page: value);

  @override
  CatalogSizeListQuery cleared() =>
      copyWith(search: '', status: SizeStatusFilter.all, page: 1);

  CatalogSizeListQuery withStatus(SizeStatusFilter value) =>
      status == value ? this : copyWith(status: value, page: 1);

  CatalogSizeListQuery withSort(CatalogSizeSortField field, bool ascending) =>
      sortField == field && sortAscending == ascending
      ? this
      : copyWith(sortField: field, sortAscending: ascending, page: 1);

  CatalogSizeListQuery copyWith({
    String? search,
    SizeStatusFilter? status,
    CatalogSizeSortField? sortField,
    bool? sortAscending,
    int? page,
    int? pageSize,
  }) => CatalogSizeListQuery(
    sizeGroupId: sizeGroupId,
    search: search ?? this.search,
    status: status ?? this.status,
    sortField: sortField ?? this.sortField,
    sortAscending: sortAscending ?? this.sortAscending,
    page: page ?? this.page,
    pageSize: pageSize ?? this.pageSize,
  );

  @override
  List<Object?> get props => [
    sizeGroupId,
    search,
    status,
    sortField,
    sortAscending,
    page,
    pageSize,
  ];
}
