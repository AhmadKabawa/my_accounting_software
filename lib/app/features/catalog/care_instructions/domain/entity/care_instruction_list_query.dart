import 'package:equatable/equatable.dart';
import 'package:accounting_software/app/core/foundation/types/paged_query.dart';
import 'care_instruction.dart';

enum CareInstructionStatusFilter { all, active, inactive }

class CareInstructionListQuery extends Equatable
    implements PagedQuery<CareInstructionListQuery> {
  const CareInstructionListQuery({
    this.search = '',
    this.status = CareInstructionStatusFilter.all,
    this.careType,
    this.page = 1,
    this.pageSize = 25,
  });

  @override
  final String search;
  final CareInstructionStatusFilter status;
  final CareType? careType;
  @override
  final int page;
  @override
  final int pageSize;

  @override
  bool get hasActiveFilters =>
      search.isNotEmpty ||
      status != CareInstructionStatusFilter.all ||
      careType != null;

  @override
  CareInstructionListQuery withSearch(String value) =>
      copyWith(search: value, page: 1);

  @override
  CareInstructionListQuery withPage(int value) => copyWith(page: value);

  @override
  CareInstructionListQuery cleared() => copyWith(
    search: '',
    status: CareInstructionStatusFilter.all,
    careType: null,
    clearCareType: true,
    page: 1,
  );

  CareInstructionListQuery copyWith({
    String? search,
    CareInstructionStatusFilter? status,
    CareType? careType,
    bool clearCareType = false,
    int? page,
    int? pageSize,
  }) => CareInstructionListQuery(
    search: search ?? this.search,
    status: status ?? this.status,
    careType: clearCareType ? null : careType ?? this.careType,
    page: page ?? this.page,
    pageSize: pageSize ?? this.pageSize,
  );

  @override
  List<Object?> get props => [search, status, careType, page, pageSize];
}
