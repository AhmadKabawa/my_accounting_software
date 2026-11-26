import 'package:equatable/equatable.dart';
import 'package:accounting_software/app/core/foundation/types/paged_query.dart';

enum OptionSetStatusFilter { all, active, inactive }

class OptionSetListQuery extends Equatable
    implements PagedQuery<OptionSetListQuery> {
  const OptionSetListQuery({
    this.search = '',
    this.status = OptionSetStatusFilter.all,
    this.page = 1,
    this.pageSize = 25,
    this.sortAscending = true,
  });
  @override
  final String search;
  final OptionSetStatusFilter status;
  @override
  final int page;
  @override
  final int pageSize;
  final bool sortAscending;
  @override
  bool get hasActiveFilters =>
      search.isNotEmpty || status != OptionSetStatusFilter.all;
  @override
  OptionSetListQuery withSearch(String value) =>
      copyWith(search: value, page: 1);
  @override
  OptionSetListQuery withPage(int value) => copyWith(page: value);
  @override
  OptionSetListQuery cleared() => OptionSetListQuery(pageSize: pageSize);
  OptionSetListQuery copyWith({
    String? search,
    OptionSetStatusFilter? status,
    int? page,
    int? pageSize,
    bool? sortAscending,
  }) => OptionSetListQuery(
    search: search ?? this.search,
    status: status ?? this.status,
    page: page ?? this.page,
    pageSize: pageSize ?? this.pageSize,
    sortAscending: sortAscending ?? this.sortAscending,
  );
  OptionSetListQuery withSort(bool ascending) =>
      copyWith(sortAscending: ascending, page: 1);
  @override
  List<Object?> get props => [search, status, page, pageSize, sortAscending];
}
