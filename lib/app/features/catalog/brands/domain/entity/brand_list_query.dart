import 'package:equatable/equatable.dart';
import 'package:accounting_software/app/core/foundation/types/paged_query.dart';

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

class BrandListQuery extends Equatable implements PagedQuery<BrandListQuery> {
  const BrandListQuery({
    this.search = '',
    this.status = BrandStatusFilter.all,
    this.sortField = BrandSortField.name,
    this.sortAscending = true,
    this.thenSorts = const [],
    this.page = 1,
    this.pageSize = 25,
  });

  @override
  final String search;
  final BrandStatusFilter status;
  final BrandSortField sortField;
  final bool sortAscending;

  /// Further criteria applied after the primary one, in priority order.
  final List<BrandSort> thenSorts;

  /// All criteria in priority order; sent to the database as one `order`.
  List<BrandSort> get sorts => [
    BrandSort(sortField, sortAscending),
    ...thenSorts,
  ];
  @override
  final int page;
  @override
  final int pageSize;

  @override
  bool get hasActiveFilters =>
      search.isNotEmpty || status != BrandStatusFilter.all;

  @override
  BrandListQuery withSearch(String value) => copyWith(search: value, page: 1);

  @override
  BrandListQuery withPage(int value) => copyWith(page: value);

  @override
  BrandListQuery cleared() =>
      copyWith(search: '', status: BrandStatusFilter.all, page: 1);

  BrandListQuery withStatus(BrandStatusFilter value) =>
      status == value ? this : copyWith(status: value, page: 1);

  BrandListQuery withSort({
    required BrandSortField field,
    required bool ascending,
  }) => sortField == field && sortAscending == ascending && thenSorts.isEmpty
      ? this
      : copyWith(
          sortField: field,
          sortAscending: ascending,
          thenSorts: const [],
          page: 1,
        );

  BrandListQuery withSorts(List<BrandSort> values) {
    if (values.isEmpty || hasSameSorts(values)) return this;
    final primary = values.first;
    return copyWith(
      sortField: primary.field,
      sortAscending: primary.ascending,
      thenSorts: values.skip(1).toList(),
      page: 1,
    );
  }

  bool hasSameSorts(List<BrandSort> values) {
    if (values.isEmpty) return false;
    final primary = values.first;
    final secondary = values.skip(1).toList();
    return sortField == primary.field &&
        sortAscending == primary.ascending &&
        thenSorts.length == secondary.length &&
        thenSorts.asMap().entries.every((entry) => entry.value == secondary[entry.key]);
  }

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
