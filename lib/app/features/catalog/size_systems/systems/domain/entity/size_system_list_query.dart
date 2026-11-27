import 'package:equatable/equatable.dart';
import 'package:accounting_software/app/core/foundation/types/paged_query.dart';
import 'package:accounting_software/app/features/catalog/size_systems/shared/domain/size_status_filter.dart';

enum SizeSystemSortField {
  name('name'),
  code('code'),
  updated('updated_at');

  const SizeSystemSortField(this.column);
  final String column;

  static SizeSystemSortField? tryParse(String? name) {
    for (final value in values) {
      if (value.name == name) return value;
    }
    return null;
  }
}

class SizeSystemListQuery extends Equatable
    implements PagedQuery<SizeSystemListQuery> {
  const SizeSystemListQuery({
    this.search = '',
    this.status = SizeStatusFilter.all,
    this.sortField = SizeSystemSortField.name,
    this.sortAscending = true,
    this.page = 1,
    this.pageSize = 25,
  });

  @override
  final String search;
  final SizeStatusFilter status;
  final SizeSystemSortField sortField;
  final bool sortAscending;
  @override
  final int page;
  @override
  final int pageSize;

  @override
  bool get hasActiveFilters =>
      search.isNotEmpty || status != SizeStatusFilter.all;

  @override
  SizeSystemListQuery withSearch(String value) =>
      copyWith(search: value, page: 1);

  @override
  SizeSystemListQuery withPage(int value) => copyWith(page: value);

  @override
  SizeSystemListQuery cleared() =>
      copyWith(search: '', status: SizeStatusFilter.all, page: 1);

  SizeSystemListQuery withStatus(SizeStatusFilter value) =>
      status == value ? this : copyWith(status: value, page: 1);

  SizeSystemListQuery withSort(SizeSystemSortField field, bool ascending) =>
      sortField == field && sortAscending == ascending
      ? this
      : copyWith(sortField: field, sortAscending: ascending, page: 1);

  SizeSystemListQuery copyWith({
    String? search,
    SizeStatusFilter? status,
    SizeSystemSortField? sortField,
    bool? sortAscending,
    int? page,
    int? pageSize,
  }) => SizeSystemListQuery(
    search: search ?? this.search,
    status: status ?? this.status,
    sortField: sortField ?? this.sortField,
    sortAscending: sortAscending ?? this.sortAscending,
    page: page ?? this.page,
    pageSize: pageSize ?? this.pageSize,
  );

  @override
  List<Object?> get props => [
    search,
    status,
    sortField,
    sortAscending,
    page,
    pageSize,
  ];
}
