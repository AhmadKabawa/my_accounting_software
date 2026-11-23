import 'package:equatable/equatable.dart';
import 'package:accounting_software/app/core/foundation/types/paged_query.dart';

enum ColorStatusFilter { all, active, inactive }

enum ColorSortField {
  order('sort_order'),
  name('name'),
  code('code');

  const ColorSortField(this.column);
  final String column;

  static ColorSortField? tryParse(String? name) {
    for (final value in values) {
      if (value.name == name) return value;
    }
    return null;
  }
}

class ColorSort extends Equatable {
  const ColorSort(this.field, this.ascending);
  final ColorSortField field;
  final bool ascending;

  @override
  List<Object?> get props => [field, ascending];
}

class ColorListQuery extends Equatable implements PagedQuery<ColorListQuery> {
  const ColorListQuery({
    this.search = '',
    this.status = ColorStatusFilter.all,
    this.sortField = ColorSortField.order,
    this.sortAscending = true,
    this.thenSorts = const [],
    this.page = 1,
    this.pageSize = 25,
  });

  @override
  final String search;
  final ColorStatusFilter status;
  final ColorSortField sortField;
  final bool sortAscending;
  final List<ColorSort> thenSorts;
  @override
  final int page;
  @override
  final int pageSize;

  List<ColorSort> get sorts => [ColorSort(sortField, sortAscending), ...thenSorts];

  bool get isFiltered => hasActiveFilters;
  @override
  bool get hasActiveFilters =>
      search.isNotEmpty || status != ColorStatusFilter.all;

  @override
  ColorListQuery withSearch(String value) => copyWith(search: value, page: 1);

  @override
  ColorListQuery withPage(int value) => copyWith(page: value);

  @override
  ColorListQuery cleared() => copyWith(
    search: '',
    status: ColorStatusFilter.all,
    page: 1,
  );

  ColorListQuery withStatus(ColorStatusFilter value) =>
      status == value ? this : copyWith(status: value, page: 1);

  ColorListQuery withSorts(List<ColorSort> values) {
    if (values.isEmpty || hasSameSorts(values)) return this;
    final primary = values.first;
    return copyWith(
      sortField: primary.field,
      sortAscending: primary.ascending,
      thenSorts: values.skip(1).toList(),
      page: 1,
    );
  }

  bool hasSameSorts(List<ColorSort> values) {
    if (values.isEmpty) return false;
    final primary = values.first;
    final secondary = values.skip(1).toList();
    return sortField == primary.field &&
        sortAscending == primary.ascending &&
        thenSorts.length == secondary.length &&
        thenSorts.asMap().entries.every((entry) => entry.value == secondary[entry.key]);
  }

  ColorListQuery copyWith({
    String? search,
    ColorStatusFilter? status,
    ColorSortField? sortField,
    bool? sortAscending,
    List<ColorSort>? thenSorts,
    int? page,
    int? pageSize,
  }) => ColorListQuery(
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
