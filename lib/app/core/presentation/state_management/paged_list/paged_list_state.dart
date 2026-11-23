import 'package:equatable/equatable.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/types/paged_query.dart';
import 'package:accounting_software/app/core/presentation/state_management/paged_list/paged_result.dart';

enum PagedListStatus { initial, loading, ready, refreshing, failed }

class PagedListState<T, Q extends PagedQuery<Q>> extends Equatable {
  const PagedListState({
    required this.query,
    this.status = PagedListStatus.initial,
    this.result,
    this.failure,
    this.selectionMode = false,
  });

  final PagedListStatus status;
  final Q query;
  final PagedResult<T>? result;
  final Failure? failure;
  final bool selectionMode;

  bool get hasData => result != null;
  bool get isInitialLoading => status == PagedListStatus.loading && !hasData;
  bool get isRefreshing => status == PagedListStatus.refreshing;

  PagedListState<T, Q> copyWith({
    PagedListStatus? status,
    Q? query,
    PagedResult<T>? result,
    Failure? failure,
    bool clearResult = false,
    bool clearFailure = false,
    bool? selectionMode,
  }) => PagedListState<T, Q>(
    status: status ?? this.status,
    query: query ?? this.query,
    result: clearResult ? null : result ?? this.result,
    failure: clearFailure ? null : failure ?? this.failure,
    selectionMode: selectionMode ?? this.selectionMode,
  );

  @override
  List<Object?> get props => [status, query, result, failure, selectionMode];
}
