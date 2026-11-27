import 'package:equatable/equatable.dart';
import 'package:accounting_software/app/core/foundation/types/paged_query.dart';
import 'package:accounting_software/app/features/catalog/size_systems/shared/domain/size_status_filter.dart';

enum SizeGroupSortField {
  name('name'),
  code('code'),
  updated('updated_at');

  const SizeGroupSortField(this.column);
  final String column;

  static SizeGroupSortField? tryParse(String? name) {
    for (final value in values) {
      if (value.name == name) return value;
    }
    return null;
  }
}

class SizeGroupListQuery extends Equatable
    implements PagedQuery<SizeGroupListQuery> {
  const SizeGroupListQuery({
    required this.sizeSystemId,
    this.search = '',
    this.status = SizeStatusFilter.all,
    this.genderId,
    this.sortField = SizeGroupSortField.name,
    this.sortAscending = true,
    this.page = 1,
    this.pageSize = 25,
  });

  /// The parent system; every request is scoped to it.
  final int sizeSystemId;
  @override
  final String search;
  final SizeStatusFilter status;

  /// Null means "any gender".
  final int? genderId;
  final SizeGroupSortField sortField;
  final bool sortAscending;
  @override
  final int page;
  @override
  final int pageSize;

  @override
  bool get hasActiveFilters =>
      search.isNotEmpty || status != SizeStatusFilter.all || genderId != null;

  @override
  SizeGroupListQuery withSearch(String value) =>
      copyWith(search: value, page: 1);

  @override
  SizeGroupListQuery withPage(int value) => copyWith(page: value);

  @override
  SizeGroupListQuery cleared() => SizeGroupListQuery(
    sizeSystemId: sizeSystemId,
    sortField: sortField,
    sortAscending: sortAscending,
    pageSize: pageSize,
  );

  SizeGroupListQuery withStatus(SizeStatusFilter value) =>
      status == value ? this : copyWith(status: value, page: 1);

  SizeGroupListQuery withGender(int? value) => genderId == value
      ? this
      : SizeGroupListQuery(
          sizeSystemId: sizeSystemId,
          search: search,
          status: status,
          genderId: value,
          sortField: sortField,
          sortAscending: sortAscending,
          pageSize: pageSize,
        );

  SizeGroupListQuery withSort(SizeGroupSortField field, bool ascending) =>
      sortField == field && sortAscending == ascending
      ? this
      : copyWith(sortField: field, sortAscending: ascending, page: 1);

  SizeGroupListQuery copyWith({
    String? search,
    SizeStatusFilter? status,
    SizeGroupSortField? sortField,
    bool? sortAscending,
    int? page,
    int? pageSize,
  }) => SizeGroupListQuery(
    sizeSystemId: sizeSystemId,
    search: search ?? this.search,
    status: status ?? this.status,
    genderId: genderId,
    sortField: sortField ?? this.sortField,
    sortAscending: sortAscending ?? this.sortAscending,
    page: page ?? this.page,
    pageSize: pageSize ?? this.pageSize,
  );

  @override
  List<Object?> get props => [
    sizeSystemId,
    search,
    status,
    genderId,
    sortField,
    sortAscending,
    page,
    pageSize,
  ];
}
