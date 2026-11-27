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

class MaterialListQuery extends Equatable implements PagedQuery<MaterialListQuery> {
  const MaterialListQuery({
    this.search = '',
    this.status = MaterialStatusFilter.all,
    this.type,
    this.sortField = MaterialSortField.name,
    this.sortAscending = true,
    this.page = 1,
    this.pageSize = 25,
  });

  @override
  final String search;
  final MaterialStatusFilter status;
  final String? type;
  final MaterialSortField sortField;
  final bool sortAscending;
  @override
  final int page;
  @override
  final int pageSize;

  @override
  bool get hasActiveFilters => search.isNotEmpty || status != MaterialStatusFilter.all || type != null;

  @override
  MaterialListQuery withSearch(String value) => copyWith(search: value, page: 1);

  @override
  MaterialListQuery withPage(int value) => copyWith(page: value);

  @override
  MaterialListQuery cleared() => copyWith(search: '', status: MaterialStatusFilter.all, type: null, page: 1);

  MaterialListQuery copyWith({
    String? search,
    MaterialStatusFilter? status,
    String? type,
    bool clearType = false,
    MaterialSortField? sortField,
    bool? sortAscending,
    int? page,
    int? pageSize,
  }) => MaterialListQuery(
    search: search ?? this.search,
    status: status ?? this.status,
    type: clearType ? null : type ?? this.type,
    sortField: sortField ?? this.sortField,
    sortAscending: sortAscending ?? this.sortAscending,
    page: page ?? this.page,
    pageSize: pageSize ?? this.pageSize,
  );

  @override
  List<Object?> get props => [search, status, type, sortField, sortAscending, page, pageSize];
}
