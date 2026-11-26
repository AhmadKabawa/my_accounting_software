import 'package:equatable/equatable.dart';
import 'package:accounting_software/app/core/foundation/types/paged_query.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/entity/catalog_attribute.dart';

enum AttributeStatusFilter { all, active, inactive }

enum AttributeFilterableFilter { all, filterable, notFilterable }

class AttributeListQuery extends Equatable
    implements PagedQuery<AttributeListQuery> {
  const AttributeListQuery({
    this.search = '',
    this.status = AttributeStatusFilter.all,
    this.dataType,
    this.filterable = AttributeFilterableFilter.all,
    this.page = 1,
    this.pageSize = 25,
  });
  @override
  final String search;
  final AttributeStatusFilter status;
  final AttributeDataType? dataType;
  final AttributeFilterableFilter filterable;
  @override
  final int page;
  @override
  final int pageSize;
  @override
  bool get hasActiveFilters =>
      search.isNotEmpty ||
      status != AttributeStatusFilter.all ||
      dataType != null ||
      filterable != AttributeFilterableFilter.all;
  @override
  AttributeListQuery withSearch(String value) =>
      copyWith(search: value, page: 1);
  @override
  AttributeListQuery withPage(int value) => copyWith(page: value);
  @override
  AttributeListQuery cleared() => AttributeListQuery(pageSize: pageSize);
  AttributeListQuery copyWith({
    String? search,
    AttributeStatusFilter? status,
    AttributeDataType? dataType,
    bool clearDataType = false,
    AttributeFilterableFilter? filterable,
    int? page,
    int? pageSize,
  }) => AttributeListQuery(
    search: search ?? this.search,
    status: status ?? this.status,
    dataType: clearDataType ? null : dataType ?? this.dataType,
    filterable: filterable ?? this.filterable,
    page: page ?? this.page,
    pageSize: pageSize ?? this.pageSize,
  );
  @override
  List<Object?> get props => [
    search,
    status,
    dataType,
    filterable,
    page,
    pageSize,
  ];
}
