import 'package:equatable/equatable.dart';
import 'package:accounting_software/app/core/foundation/types/paged_query.dart';

enum FabricTypeStatusFilter { all, active, inactive }

enum FabricTypeSortField {
  name('name'),
  code('code'),
  status('is_active');

  const FabricTypeSortField(this.column);
  final String column;

  static FabricTypeSortField? tryParse(String? key) {
    for (final value in values) {
      if (value.name == key) return value;
    }
    return null;
  }
}

class FabricTypeListQuery extends Equatable
    implements PagedQuery<FabricTypeListQuery> {
  const FabricTypeListQuery({
    this.search = '',
    this.status = FabricTypeStatusFilter.all,
    this.category,
    this.sortField = FabricTypeSortField.name,
    this.sortAscending = true,
    this.page = 1,
    this.pageSize = 25,
  });

  @override
  final String search;
  final FabricTypeStatusFilter status;
  final String? category;
  final FabricTypeSortField sortField;
  final bool sortAscending;
  @override
  final int page;
  @override
  final int pageSize;

  @override
  bool get hasActiveFilters =>
      search.isNotEmpty ||
      status != FabricTypeStatusFilter.all ||
      category != null;

  @override
  FabricTypeListQuery withSearch(String value) =>
      copyWith(search: value, page: 1);

  @override
  FabricTypeListQuery withPage(int value) => copyWith(page: value);

  @override
  FabricTypeListQuery cleared() => copyWith(
    search: '',
    status: FabricTypeStatusFilter.all,
    category: null,
    clearCategory: true,
    page: 1,
  );

  FabricTypeListQuery copyWith({
    String? search,
    FabricTypeStatusFilter? status,
    String? category,
    bool clearCategory = false,
    FabricTypeSortField? sortField,
    bool? sortAscending,
    int? page,
    int? pageSize,
  }) => FabricTypeListQuery(
    search: search ?? this.search,
    status: status ?? this.status,
    category: clearCategory ? null : category ?? this.category,
    sortField: sortField ?? this.sortField,
    sortAscending: sortAscending ?? this.sortAscending,
    page: page ?? this.page,
    pageSize: pageSize ?? this.pageSize,
  );

  @override
  List<Object?> get props => [
    search,
    status,
    category,
    sortField,
    sortAscending,
    page,
    pageSize,
  ];
}
