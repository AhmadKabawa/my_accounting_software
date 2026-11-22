import 'package:equatable/equatable.dart';

enum BrandStatusFilter { all, active, inactive }

/// The fields the server can sort brands by (product count is not one: it
/// needs a view/RPC, see docs/audit/UI_SAAS_VERIFY.md).
enum BrandSortField {
  name('name'),
  status('is_active'),
  created('created_at');

  const BrandSortField(this.column);
  final String column;

  static BrandSortField? tryParse(String? key) {
    for (final field in values) {
      if (field.name == key) return field;
    }
    return null;
  }
}

class BrandListQuery extends Equatable {
  const BrandListQuery({
    this.search = '',
    this.status = BrandStatusFilter.all,
    this.sortField = BrandSortField.name,
    this.sortAscending = true,
    this.page = 1,
    this.pageSize = 25,
  });

  final String search;
  final BrandStatusFilter status;
  final BrandSortField sortField;
  final bool sortAscending;
  final int page;
  final int pageSize;

  BrandListQuery copyWith({
    String? search,
    BrandStatusFilter? status,
    BrandSortField? sortField,
    bool? sortAscending,
    int? page,
    int? pageSize,
  }) => BrandListQuery(
    search: search ?? this.search,
    status: status ?? this.status,
    sortField: sortField ?? this.sortField,
    sortAscending: sortAscending ?? this.sortAscending,
    page: page ?? this.page,
    pageSize: pageSize ?? this.pageSize,
  );

  @override
  List<Object?> get props => [search, status, sortField, sortAscending, page, pageSize];
}
