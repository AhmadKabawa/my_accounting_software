import 'package:equatable/equatable.dart';
import 'package:accounting_software/app/core/foundation/types/paged_query.dart';

enum SportStatusFilter { all, active, inactive }

enum SportSortField {
  order('sort_order'),
  name('name'),
  code('code');

  const SportSortField(this.column);
  final String column;

  static SportSortField? tryParse(String? name) {
    for (final value in values) {
      if (value.name == name) return value;
    }
    return null;
  }
}

class SportSort extends Equatable {
  const SportSort(this.field, this.ascending);
  final SportSortField field;
  final bool ascending;

  @override
  List<Object?> get props => [field, ascending];
}

class SportListQuery extends Equatable implements PagedQuery<SportListQuery> {
  const SportListQuery({
    this.search = '',
    this.status = SportStatusFilter.all,
    this.sortField = SportSortField.order,
    this.sortAscending = true,
    this.thenSorts = const [],
    this.page = 1,
    this.pageSize = 25,
  });

  @override
  final String search;
  final SportStatusFilter status;
  final SportSortField sortField;
  final bool sortAscending;
  final List<SportSort> thenSorts;
  @override
  final int page;
  @override
  final int pageSize;

  List<SportSort> get sorts => [
    SportSort(sortField, sortAscending),
    ...thenSorts,
  ];

  bool get isFiltered => hasActiveFilters;
  @override
  bool get hasActiveFilters =>
      search.isNotEmpty || status != SportStatusFilter.all;

  @override
  SportListQuery withSearch(String value) => copyWith(search: value, page: 1);

  @override
  SportListQuery withPage(int value) => copyWith(page: value);

  @override
  SportListQuery cleared() =>
      copyWith(search: '', status: SportStatusFilter.all, page: 1);

  SportListQuery withStatus(SportStatusFilter value) =>
      status == value ? this : copyWith(status: value, page: 1);

  SportListQuery withSorts(List<SportSort> values) {
    if (values.isEmpty || hasSameSorts(values)) return this;
    final primary = values.first;
    return copyWith(
      sortField: primary.field,
      sortAscending: primary.ascending,
      thenSorts: values.skip(1).toList(),
      page: 1,
    );
  }

  bool hasSameSorts(List<SportSort> values) {
    if (values.isEmpty) return false;
    final primary = values.first;
    final secondary = values.skip(1).toList();
    return sortField == primary.field &&
        sortAscending == primary.ascending &&
        thenSorts.length == secondary.length &&
        thenSorts.asMap().entries.every(
          (entry) => entry.value == secondary[entry.key],
        );
  }

  SportListQuery copyWith({
    String? search,
    SportStatusFilter? status,
    SportSortField? sortField,
    bool? sortAscending,
    List<SportSort>? thenSorts,
    int? page,
    int? pageSize,
  }) => SportListQuery(
    search: search ?? this.search,
    status: status ?? this.status,
    sortField: sortField ?? this.sortField,
    sortAscending: sortAscending ?? this.sortAscending,
    thenSorts: thenSorts ?? this.thenSorts,
    page: page ?? this.page,
    pageSize: pageSize ?? this.pageSize,
  );

  @override
  List<Object?> get props => [
    search,
    status,
    sortField,
    sortAscending,
    thenSorts,
    page,
    pageSize,
  ];
}
