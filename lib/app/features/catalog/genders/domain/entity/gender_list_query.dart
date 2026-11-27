import 'package:equatable/equatable.dart';
import 'package:accounting_software/app/core/foundation/types/paged_query.dart';

enum GenderStatusFilter { all, active, inactive }

enum GenderSortField {
  order('sort_order'),
  name('name'),
  code('code');

  const GenderSortField(this.column);
  final String column;

  static GenderSortField? tryParse(String? value) {
    for (final field in values) {
      if (field.name == value) return field;
    }
    return null;
  }
}

class GenderSort extends Equatable {
  const GenderSort(this.field, this.ascending);
  final GenderSortField field;
  final bool ascending;
  @override
  List<Object?> get props => [field, ascending];
}

class GenderListQuery extends Equatable implements PagedQuery<GenderListQuery> {
  const GenderListQuery({
    this.search = '',
    this.status = GenderStatusFilter.all,
    this.sortField = GenderSortField.order,
    this.sortAscending = true,
    this.thenSorts = const [],
    this.page = 1,
    this.pageSize = 25,
  });

  @override
  final String search;
  final GenderStatusFilter status;
  final GenderSortField sortField;
  final bool sortAscending;
  final List<GenderSort> thenSorts;
  @override
  final int page;
  @override
  final int pageSize;

  List<GenderSort> get sorts => [GenderSort(sortField, sortAscending), ...thenSorts];
  @override
  bool get hasActiveFilters => search.isNotEmpty || status != GenderStatusFilter.all;
  @override
  GenderListQuery withSearch(String value) => copyWith(search: value, page: 1);
  @override
  GenderListQuery withPage(int value) => copyWith(page: value);
  @override
  GenderListQuery cleared() => copyWith(search: '', status: GenderStatusFilter.all, page: 1);
  GenderListQuery withStatus(GenderStatusFilter value) =>
      value == status ? this : copyWith(status: value, page: 1);
  GenderListQuery withSorts(List<GenderSort> values) {
    if (values.isEmpty || hasSameSorts(values)) return this;
    return copyWith(
      sortField: values.first.field,
      sortAscending: values.first.ascending,
      thenSorts: values.skip(1).toList(),
      page: 1,
    );
  }
  bool hasSameSorts(List<GenderSort> values) =>
      values.isNotEmpty &&
      sortField == values.first.field &&
      sortAscending == values.first.ascending &&
      thenSorts.length == values.skip(1).length &&
      thenSorts.asMap().entries.every((entry) => entry.value == values.skip(1).elementAt(entry.key));
  GenderListQuery copyWith({
    String? search,
    GenderStatusFilter? status,
    GenderSortField? sortField,
    bool? sortAscending,
    List<GenderSort>? thenSorts,
    int? page,
    int? pageSize,
  }) => GenderListQuery(
    search: search ?? this.search,
    status: status ?? this.status,
    sortField: sortField ?? this.sortField,
    sortAscending: sortAscending ?? this.sortAscending,
    thenSorts: thenSorts ?? this.thenSorts,
    page: page ?? this.page,
    pageSize: pageSize ?? this.pageSize,
  );
  @override
  List<Object?> get props => [search, status, sortField, sortAscending, thenSorts, page, pageSize];
}
