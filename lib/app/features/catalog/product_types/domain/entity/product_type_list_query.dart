import 'package:equatable/equatable.dart';
import 'package:accounting_software/app/core/foundation/types/paged_query.dart';

enum ProductTypeStatusFilter { all, active, inactive }

class ProductTypeListQuery extends Equatable
    implements PagedQuery<ProductTypeListQuery> {
  const ProductTypeListQuery({
    this.search = '',
    this.status = ProductTypeStatusFilter.all,
    this.page = 1,
    this.pageSize = 25,
  });

  @override
  final String search;
  final ProductTypeStatusFilter status;
  @override
  final int page;
  @override
  final int pageSize;

  @override
  bool get hasActiveFilters =>
      search.trim().isNotEmpty || status != ProductTypeStatusFilter.all;

  @override
  ProductTypeListQuery withSearch(String value) =>
      copyWith(search: value, page: 1);

  @override
  ProductTypeListQuery withPage(int value) => copyWith(page: value);

  @override
  ProductTypeListQuery cleared() =>
      copyWith(search: '', status: ProductTypeStatusFilter.all, page: 1);

  ProductTypeListQuery withStatus(ProductTypeStatusFilter value) =>
      status == value ? this : copyWith(status: value, page: 1);

  ProductTypeListQuery copyWith({
    String? search,
    ProductTypeStatusFilter? status,
    int? page,
    int? pageSize,
  }) => ProductTypeListQuery(
    search: search ?? this.search,
    status: status ?? this.status,
    page: page ?? this.page,
    pageSize: pageSize ?? this.pageSize,
  );

  @override
  List<Object?> get props => [search, status, page, pageSize];
}
