import 'package:equatable/equatable.dart';

enum BrandStatusFilter { all, active, inactive }

class BrandListQuery extends Equatable {
  const BrandListQuery({
    this.search = '',
    this.status = BrandStatusFilter.all,
    this.sortAscending = true,
    this.page = 1,
    this.pageSize = 25,
  });

  final String search;
  final BrandStatusFilter status;
  final bool sortAscending;
  final int page;
  final int pageSize;

  BrandListQuery copyWith({
    String? search,
    BrandStatusFilter? status,
    bool? sortAscending,
    int? page,
    int? pageSize,
  }) => BrandListQuery(
    search: search ?? this.search,
    status: status ?? this.status,
    sortAscending: sortAscending ?? this.sortAscending,
    page: page ?? this.page,
    pageSize: pageSize ?? this.pageSize,
  );

  @override
  List<Object?> get props => [search, status, sortAscending, page, pageSize];
}
