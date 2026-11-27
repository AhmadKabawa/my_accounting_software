import 'package:equatable/equatable.dart';
import 'package:accounting_software/app/core/foundation/types/paged_query.dart';

enum FabricTypeStatusFilter { all, active, inactive }

enum FabricTypeSortField {
  name('name'),
  code('code'),
  status('is_active');

  const FabricTypeSortField(this.column);
  final String column;

  static FabricTypeSortField? tryParse(String? key) {
    for (final value in values) {
      if (value.name == key) return value;
    }
    return null;
  }
}

class FabricTypeSort extends Equatable {
  const FabricTypeSort(this.field, this.ascending);
  final FabricTypeSortField field;
  final bool ascending;

  @override
  List<Object?> get props => [field, ascending];
}

class FabricTypeListQuery extends Equatable
    implements PagedQuery<FabricTypeListQuery> {
  const FabricTypeListQuery({
    this.search = '',
    this.status = FabricTypeStatusFilter.all,
    this.category,
    this.sortField = FabricTypeSortField.name,
    this.sortAscending = true,
    this.thenSorts = const [],
    this.page = 1,
    this.pageSize = 25,
  });

  @override
  final String search;
  final FabricTypeStatusFilter status;
  final String? category;
  final FabricTypeSortField sortField;
  final bool sortAscending;
  final List<FabricTypeSort> thenSorts;
  @override
  final int page;
  @override
  final int pageSize;

  List<FabricTypeSort> get sorts => [
    FabricTypeSort(sortField, sortAscending),
    ...thenSorts,
  ];

  @override
  bool get hasActiveFilters =>
      search.isNotEmpty ||
      status != FabricTypeStatusFilter.all ||
      category != null;

  @override
  FabricTypeListQuery withSearch(String value) =>
      copyWith(search: value, page: 1);

  @override
  FabricTypeListQuery withPage(int value) => copyWith(page: value);

  @override
  FabricTypeListQuery cleared() => copyWith(
    search: '',
    status: FabricTypeStatusFilter.all,
    category: null,
    clearCategory: true,
    page: 1,
  );

  FabricTypeListQuery withSorts(List<FabricTypeSort> values) {
    if (values.isEmpty || hasSameSorts(values)) return this;
    final primary = values.first;
    return copyWith(
      sortField: primary.field,
      sortAscending: primary.ascending,
      thenSorts: values.skip(1).toList(),
      page: 1,
    );
  }

  bool hasSameSorts(List<FabricTypeSort> values) {
    if (values.isEmpty || values.length != sorts.length) return false;
    return values.asMap().entries.every(
      (entry) => entry.value == sorts[entry.key],
    );
  }

  FabricTypeListQuery copyWith({
    String? search,
    FabricTypeStatusFilter? status,
    String? category,
    bool clearCategory = false,
    FabricTypeSortField? sortField,
    bool? sortAscending,
    List<FabricTypeSort>? thenSorts,
    int? page,
    int? pageSize,
  }) => FabricTypeListQuery(
    search: search ?? this.search,
    status: status ?? this.status,
    category: clearCategory ? null : category ?? this.category,
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
    category,
    sortField,
    sortAscending,
    thenSorts,
    page,
    pageSize,
  ];
}
