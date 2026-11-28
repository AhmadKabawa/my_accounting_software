import 'package:equatable/equatable.dart';
import 'package:accounting_software/app/core/foundation/types/paged_query.dart';

enum CollectionStatusFilter { all, active, inactive }

enum CollectionSortField {
  name('name'),
  startDate('start_date');

  const CollectionSortField(this.column);
  final String column;

  static CollectionSortField? tryParse(String? key) {
    for (final value in values) {
      if (value.name == key) return value;
    }
    return null;
  }
}

class CollectionSort extends Equatable {
  const CollectionSort(this.field, this.ascending);
  final CollectionSortField field;
  final bool ascending;
  @override
  List<Object?> get props => [field, ascending];
}

class CollectionListQuery extends Equatable
    implements PagedQuery<CollectionListQuery> {
  const CollectionListQuery({
    this.search = '',
    this.status = CollectionStatusFilter.all,
    this.sortField = CollectionSortField.name,
    this.sortAscending = true,
    this.thenSorts = const [],
    this.page = 1,
    this.pageSize = 25,
  });

  @override
  final String search;
  final CollectionStatusFilter status;
  final CollectionSortField sortField;
  final bool sortAscending;
  final List<CollectionSort> thenSorts;
  @override
  final int page;
  @override
  final int pageSize;

  List<CollectionSort> get sorts => [
    CollectionSort(sortField, sortAscending),
    ...thenSorts,
  ];

  @override
  bool get hasActiveFilters =>
      search.isNotEmpty || status != CollectionStatusFilter.all;

  @override
  CollectionListQuery withSearch(String value) =>
      copyWith(search: value, page: 1);

  @override
  CollectionListQuery withPage(int value) => copyWith(page: value);

  @override
  CollectionListQuery cleared() => copyWith(
    search: '',
    status: CollectionStatusFilter.all,
    page: 1,
  );

  CollectionListQuery withSorts(List<CollectionSort> values) {
    if (values.isEmpty || hasSameSorts(values)) return this;
    final primary = values.first;
    return copyWith(
      sortField: primary.field,
      sortAscending: primary.ascending,
      thenSorts: values.skip(1).toList(),
      page: 1,
    );
  }

  bool hasSameSorts(List<CollectionSort> values) {
    if (values.isEmpty || values.length != sorts.length) return false;
    return values.asMap().entries.every(
      (entry) => entry.value == sorts[entry.key],
    );
  }

  CollectionListQuery copyWith({
    String? search,
    CollectionStatusFilter? status,
    CollectionSortField? sortField,
    bool? sortAscending,
    List<CollectionSort>? thenSorts,
    int? page,
    int? pageSize,
  }) => CollectionListQuery(
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
    search, status, sortField, sortAscending, thenSorts, page, pageSize,
  ];
}
