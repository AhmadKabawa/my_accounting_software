import 'package:equatable/equatable.dart';
import 'package:accounting_software/app/core/foundation/types/paged_query.dart';
import 'package:accounting_software/app/features/catalog/units/domain/entity/catalog_unit.dart';

enum UnitStatusFilter { all, active, inactive }

class UnitListQuery extends Equatable implements PagedQuery<UnitListQuery> {
  const UnitListQuery({
    this.search = '',
    this.status = UnitStatusFilter.all,
    this.type,
    this.page = 1,
    this.pageSize = 25,
  });
  @override
  final String search;
  final UnitStatusFilter status;
  final UnitType? type;
  @override
  final int page;
  @override
  final int pageSize;
  @override
  bool get hasActiveFilters =>
      search.isNotEmpty || status != UnitStatusFilter.all || type != null;
  @override
  UnitListQuery withSearch(String value) => copyWith(search: value, page: 1);
  @override
  UnitListQuery withPage(int value) => copyWith(page: value);
  @override
  UnitListQuery cleared() => UnitListQuery(pageSize: pageSize);
  UnitListQuery copyWith({
    String? search,
    UnitStatusFilter? status,
    UnitType? type,
    bool clearType = false,
    int? page,
    int? pageSize,
  }) => UnitListQuery(
    search: search ?? this.search,
    status: status ?? this.status,
    type: clearType ? null : type ?? this.type,
    page: page ?? this.page,
    pageSize: pageSize ?? this.pageSize,
  );
  @override
  List<Object?> get props => [search, status, type, page, pageSize];
}
