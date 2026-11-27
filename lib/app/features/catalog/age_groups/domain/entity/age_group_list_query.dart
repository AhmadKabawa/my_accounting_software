import 'package:equatable/equatable.dart';
import 'package:accounting_software/app/core/foundation/types/paged_query.dart';

enum AgeGroupStatusFilter { all, active, inactive }

enum AgeGroupSortField {
  order('sort_order'),
  name('name');

  const AgeGroupSortField(this.column);
  final String column;
  static AgeGroupSortField? tryParse(String? value) {
    for (final field in values) {
      if (field.name == value) return field;
    }
    return null;
  }
}

class AgeGroupListQuery extends Equatable
    implements PagedQuery<AgeGroupListQuery> {
  const AgeGroupListQuery({
    this.search = '',
    this.status = AgeGroupStatusFilter.all,
    this.sortField = AgeGroupSortField.order,
    this.sortAscending = true,
    this.page = 1,
    this.pageSize = 25,
  });
  @override
  final String search;
  final AgeGroupStatusFilter status;
  final AgeGroupSortField sortField;
  final bool sortAscending;
  @override
  final int page;
  @override
  final int pageSize;
  @override
  bool get hasActiveFilters =>
      search.isNotEmpty || status != AgeGroupStatusFilter.all;
  @override
  AgeGroupListQuery withSearch(String value) =>
      copyWith(search: value, page: 1);
  @override
  AgeGroupListQuery withPage(int value) => copyWith(page: value);
  @override
  AgeGroupListQuery cleared() =>
      copyWith(search: '', status: AgeGroupStatusFilter.all, page: 1);
  AgeGroupListQuery withStatus(AgeGroupStatusFilter value) =>
      status == value ? this : copyWith(status: value, page: 1);
  AgeGroupListQuery withSort(AgeGroupSortField field, bool ascending) =>
      sortField == field && sortAscending == ascending
      ? this
      : copyWith(sortField: field, sortAscending: ascending, page: 1);
  AgeGroupListQuery copyWith({
    String? search,
    AgeGroupStatusFilter? status,
    AgeGroupSortField? sortField,
    bool? sortAscending,
    int? page,
    int? pageSize,
  }) => AgeGroupListQuery(
    search: search ?? this.search,
    status: status ?? this.status,
    sortField: sortField ?? this.sortField,
    sortAscending: sortAscending ?? this.sortAscending,
    page: page ?? this.page,
    pageSize: pageSize ?? this.pageSize,
  );
  @override
  List<Object?> get props => [
    search,
    status,
    sortField,
    sortAscending,
    page,
    pageSize,
  ];
}
