import 'package:equatable/equatable.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/config/app_config.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand_list_query.dart';

enum BrandsListStatus { initial, loading, ready, refreshing, failed }

class BrandsListState extends Equatable {
  const BrandsListState({
    this.status = BrandsListStatus.initial,
    this.query = const BrandListQuery(
      page: AppConfig.defaultPage,
      pageSize: AppConfig.defaultPageSize,
    ),
    this.result,
    this.failure,
  });

  final BrandsListStatus status;
  final BrandListQuery query;
  final PaginatedResult<Brand>? result;
  final Failure? failure;

  bool get hasData => result != null;
  bool get isInitialLoading => status == BrandsListStatus.loading && !hasData;
  bool get isRefreshing => status == BrandsListStatus.refreshing;

  BrandsListState copyWith({
    BrandsListStatus? status,
    BrandListQuery? query,
    PaginatedResult<Brand>? result,
    Failure? failure,
    bool clearResult = false,
    bool clearFailure = false,
  }) => BrandsListState(
    status: status ?? this.status,
    query: query ?? this.query,
    result: clearResult ? null : result ?? this.result,
    failure: clearFailure ? null : failure ?? this.failure,
  );

  @override
  List<Object?> get props => [status, query, result, failure];
}
