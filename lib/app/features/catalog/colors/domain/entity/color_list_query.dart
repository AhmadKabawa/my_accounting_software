import 'package:equatable/equatable.dart';

enum ColorStatusFilter { all, active, inactive }

/// What the list is ordered by. [order] is the manual `sort_order` (then
/// name), the default that the column headers do not highlight.
enum ColorSortField { order, name, code }

class ColorListQuery extends Equatable {
  const ColorListQuery({
    this.search = '',
    this.status = ColorStatusFilter.all,
    this.sortField = ColorSortField.order,
    this.sortAscending = true,
    this.page = 1,
    this.pageSize = 25,
  });

  final String search;
  final ColorStatusFilter status;
  final ColorSortField sortField;
  final bool sortAscending;
  final int page;
  final int pageSize;

  bool get isFiltered => search.isNotEmpty || status != ColorStatusFilter.all;

  ColorListQuery copyWith({
    String? search,
    ColorStatusFilter? status,
    ColorSortField? sortField,
    bool? sortAscending,
    int? page,
    int? pageSize,
  }) => ColorListQuery(
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
