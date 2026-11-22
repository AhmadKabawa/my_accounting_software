import 'package:equatable/equatable.dart';

enum BrandStatusFilter { all, active, inactive }

/// The fields the server can sort brands by. `newest` orders by `id`: the
/// table has no `created_at` column, and ids grow with creation. Product count
/// is not sortable (it needs a view/RPC, see docs/audit/UI_SAAS_VERIFY.md).
enum BrandSortField {
  name('name'),
  status('is_active'),
  newest('id'),
  updated('updated_at');

  const BrandSortField(this.column);
  final String column;

  static BrandSortField? tryParse(String? key) {
    for (final field in values) {
      if (field.name == key) return field;
    }
    return null;
  }
}

/// One sort criterion: a field and its direction.
class BrandSort extends Equatable {
  const BrandSort(this.field, this.ascending);
  final BrandSortField field;
  final bool ascending;

  @override
  List<Object?> get props => [field, ascending];
}

class BrandListQuery extends Equatable {
  const BrandListQuery({
    this.search = '',
    this.status = BrandStatusFilter.all,
    this.sortField = BrandSortField.name,
    this.sortAscending = true,
    this.thenSorts = const [],
    this.page = 1,
    this.pageSize = 25,
  });

  final String search;
  final BrandStatusFilter status;
  final BrandSortField sortField;
  final bool sortAscending;

  /// Further criteria applied after the primary one (at most one more).
  final List<BrandSort> thenSorts;

  /// All criteria in priority order; sent to the database as one `order`.
  List<BrandSort> get sorts => [
    BrandSort(sortField, sortAscending),
    ...thenSorts,
  ];
  final int page;
  final int pageSize;

  BrandListQuery copyWith({
    String? search,
    BrandStatusFilter? status,
    BrandSortField? sortField,
    bool? sortAscending,
    List<BrandSort>? thenSorts,
    int? page,
    int? pageSize,
  }) => BrandListQuery(
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
