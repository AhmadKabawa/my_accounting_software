import 'package:equatable/equatable.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/config/app_config.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/entity/catalog_color.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/entity/color_list_query.dart';

enum ColorsListStatus { initial, loading, ready, refreshing, failed }

class ColorsListState extends Equatable {
  const ColorsListState({
    this.status = ColorsListStatus.initial,
    this.query = const ColorListQuery(
      page: AppConfig.defaultPage,
      pageSize: AppConfig.defaultPageSize,
    ),
    this.result,
    this.failure,
  });

  final ColorsListStatus status;
  final ColorListQuery query;
  final PaginatedResult<CatalogColor>? result;
  final Failure? failure;

  bool get hasData => result != null;
  bool get isInitialLoading => status == ColorsListStatus.loading && !hasData;
  bool get isRefreshing => status == ColorsListStatus.refreshing;

  ColorsListState copyWith({
    ColorsListStatus? status,
    ColorListQuery? query,
    PaginatedResult<CatalogColor>? result,
    Failure? failure,
    bool clearResult = false,
    bool clearFailure = false,
  }) => ColorsListState(
    status: status ?? this.status,
    query: query ?? this.query,
    result: clearResult ? null : result ?? this.result,
    failure: clearFailure ? null : failure ?? this.failure,
  );

  @override
  List<Object?> get props => [status, query, result, failure];
}
