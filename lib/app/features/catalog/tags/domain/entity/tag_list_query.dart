import 'package:equatable/equatable.dart';
import 'package:accounting_software/app/core/foundation/types/paged_query.dart';

enum TagStatusFilter { all, active, inactive }

enum TagSortField {
  name('name'),
  slug('slug');

  const TagSortField(this.column);
  final String column;

  static TagSortField? tryParse(String? name) {
    for (final value in values) {
      if (value.name == name) return value;
    }
    return null;
  }
}

class TagSort extends Equatable {
  const TagSort(this.field, this.ascending);
  final TagSortField field;
  final bool ascending;

  @override
  List<Object?> get props => [field, ascending];
}

class TagListQuery extends Equatable implements PagedQuery<TagListQuery> {
  const TagListQuery({
    this.search = '',
    this.status = TagStatusFilter.all,
    this.sortField = TagSortField.name,
    this.sortAscending = true,
    this.thenSorts = const [],
    this.page = 1,
    this.pageSize = 25,
  });

  @override
  final String search;
  final TagStatusFilter status;
  final TagSortField sortField;
  final bool sortAscending;
  final List<TagSort> thenSorts;
  @override
  final int page;
  @override
  final int pageSize;

  List<TagSort> get sorts => [TagSort(sortField, sortAscending), ...thenSorts];

  bool get isFiltered => hasActiveFilters;
  @override
  bool get hasActiveFilters =>
      search.isNotEmpty || status != TagStatusFilter.all;

  @override
  TagListQuery withSearch(String value) => copyWith(search: value, page: 1);

  @override
  TagListQuery withPage(int value) => copyWith(page: value);

  @override
  TagListQuery cleared() =>
      copyWith(search: '', status: TagStatusFilter.all, page: 1);

  TagListQuery withStatus(TagStatusFilter value) =>
      status == value ? this : copyWith(status: value, page: 1);

  TagListQuery withSorts(List<TagSort> values) {
    if (values.isEmpty || hasSameSorts(values)) return this;
    final primary = values.first;
    return copyWith(
      sortField: primary.field,
      sortAscending: primary.ascending,
      thenSorts: values.skip(1).toList(),
      page: 1,
    );
  }

  bool hasSameSorts(List<TagSort> values) {
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

  TagListQuery copyWith({
    String? search,
    TagStatusFilter? status,
    TagSortField? sortField,
    bool? sortAscending,
    List<TagSort>? thenSorts,
    int? page,
    int? pageSize,
  }) => TagListQuery(
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
