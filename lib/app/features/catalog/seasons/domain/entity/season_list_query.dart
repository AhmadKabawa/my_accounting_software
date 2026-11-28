import 'package:equatable/equatable.dart';
import 'package:accounting_software/app/core/foundation/types/paged_query.dart';

enum SeasonStatusFilter { all, active, inactive }

enum SeasonSortField {
  startDate('start_date');

  const SeasonSortField(this.column);
  final String column;

  static SeasonSortField? tryParse(String? key) {
    for (final value in values) {
      if (value.name == key) return value;
    }
    return null;
  }
}

class SeasonSort extends Equatable {
  const SeasonSort(this.field, this.ascending);
  final SeasonSortField field;
  final bool ascending;
  @override
  List<Object?> get props => [field, ascending];
}

class SeasonListQuery extends Equatable
    implements PagedQuery<SeasonListQuery> {
  const SeasonListQuery({
    this.search = '',
    this.status = SeasonStatusFilter.all,
    this.type,
    this.sortField = SeasonSortField.startDate,
    this.sortAscending = true,
    this.thenSorts = const [],
    this.page = 1,
    this.pageSize = 25,
  });

  @override
  final String search;
  final SeasonStatusFilter status;
  final String? type;
  final SeasonSortField sortField;
  final bool sortAscending;
  final List<SeasonSort> thenSorts;
  @override
  final int page;
  @override
  final int pageSize;

  List<SeasonSort> get sorts => [
    SeasonSort(sortField, sortAscending),
    ...thenSorts,
  ];

  @override
  bool get hasActiveFilters =>
      search.isNotEmpty || status != SeasonStatusFilter.all || type != null;

  @override
  SeasonListQuery withSearch(String value) =>
      copyWith(search: value, page: 1);

  @override
  SeasonListQuery withPage(int value) => copyWith(page: value);

  @override
  SeasonListQuery cleared() => copyWith(
    search: '',
    status: SeasonStatusFilter.all,
    type: null,
    clearType: true,
    page: 1,
  );

  SeasonListQuery withSorts(List<SeasonSort> values) {
    if (values.isEmpty || hasSameSorts(values)) return this;
    final primary = values.first;
    return copyWith(
      sortField: primary.field,
      sortAscending: primary.ascending,
      thenSorts: values.skip(1).toList(),
      page: 1,
    );
  }

  bool hasSameSorts(List<SeasonSort> values) {
    if (values.isEmpty || values.length != sorts.length) return false;
    return values.asMap().entries.every(
      (entry) => entry.value == sorts[entry.key],
    );
  }

  SeasonListQuery copyWith({
    String? search,
    SeasonStatusFilter? status,
    String? type,
    bool clearType = false,
    SeasonSortField? sortField,
    bool? sortAscending,
    List<SeasonSort>? thenSorts,
    int? page,
    int? pageSize,
  }) => SeasonListQuery(
    search: search ?? this.search,
    status: status ?? this.status,
    type: clearType ? null : type ?? this.type,
    sortField: sortField ?? this.sortField,
    sortAscending: sortAscending ?? this.sortAscending,
    thenSorts: thenSorts ?? this.thenSorts,
    page: page ?? this.page,
    pageSize: pageSize ?? this.pageSize,
  );

  @override
  List<Object?> get props => [
    search, status, type, sortField, sortAscending, thenSorts, page, pageSize,
  ];
}
