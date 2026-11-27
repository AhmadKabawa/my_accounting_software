import 'package:equatable/equatable.dart';
import 'package:accounting_software/app/core/foundation/types/paged_query.dart';

enum MaterialStatusFilter { all, active, inactive }

enum MaterialSortField {
  name('name'),
  code('code'),
  status('is_active');

  const MaterialSortField(this.column);
  final String column;

  static MaterialSortField? tryParse(String? key) {
    for (final value in values) {
      if (value.name == key) return value;
    }
    return null;
  }
}

class MaterialSort extends Equatable {
  const MaterialSort(this.field, this.ascending);
  final MaterialSortField field;
  final bool ascending;

  @override
  List<Object?> get props => [field, ascending];
}

class MaterialListQuery extends Equatable
    implements PagedQuery<MaterialListQuery> {
  const MaterialListQuery({
    this.search = '',
    this.status = MaterialStatusFilter.all,
    this.type,
    this.sortField = MaterialSortField.name,
    this.sortAscending = true,
    this.thenSorts = const [],
    this.page = 1,
    this.pageSize = 25,
  });

  @override
  final String search;
  final MaterialStatusFilter status;
  final String? type;
  final MaterialSortField sortField;
  final bool sortAscending;
  final List<MaterialSort> thenSorts;
  @override
  final int page;
  @override
  final int pageSize;

  List<MaterialSort> get sorts => [
    MaterialSort(sortField, sortAscending),
    ...thenSorts,
  ];

  @override
  bool get hasActiveFilters =>
      search.isNotEmpty || status != MaterialStatusFilter.all || type != null;

  @override
  MaterialListQuery withSearch(String value) =>
      copyWith(search: value, page: 1);

  @override
  MaterialListQuery withPage(int value) => copyWith(page: value);

  @override
  MaterialListQuery cleared() => copyWith(
    search: '',
    status: MaterialStatusFilter.all,
    type: null,
    clearType: true,
    page: 1,
  );

  MaterialListQuery withSorts(List<MaterialSort> values) {
    if (values.isEmpty || hasSameSorts(values)) return this;
    final primary = values.first;
    return copyWith(
      sortField: primary.field,
      sortAscending: primary.ascending,
      thenSorts: values.skip(1).toList(),
      page: 1,
    );
  }

  bool hasSameSorts(List<MaterialSort> values) {
    if (values.isEmpty || values.length != sorts.length) return false;
    return values.asMap().entries.every(
      (entry) => entry.value == sorts[entry.key],
    );
  }

  MaterialListQuery copyWith({
    String? search,
    MaterialStatusFilter? status,
    String? type,
    bool clearType = false,
    MaterialSortField? sortField,
    bool? sortAscending,
    List<MaterialSort>? thenSorts,
    int? page,
    int? pageSize,
  }) => MaterialListQuery(
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
    search,
    status,
    type,
    sortField,
    sortAscending,
    thenSorts,
    page,
    pageSize,
  ];
}
