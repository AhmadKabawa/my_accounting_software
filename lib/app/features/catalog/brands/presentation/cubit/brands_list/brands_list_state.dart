import 'package:equatable/equatable.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand_list_query.dart';

enum BrandsListStatus { initial, loading, success, failure }

/// Immutable snapshot for the Brands list. A refresh can retain [result]
/// while exposing [failure], so transient errors never discard visible rows.
class BrandsListState extends Equatable {
  const BrandsListState({
    this.status = BrandsListStatus.initial,
    this.query,
    this.result,
    this.failure,
  });

  final BrandsListStatus status;
  final BrandListQuery? query;
  final PaginatedResult<Brand>? result;
  final Failure? failure;

  bool get isInitial => status == BrandsListStatus.initial;
  bool get isLoading => status == BrandsListStatus.loading;
  bool get hasContent => result != null;
  bool get hasFailure => failure != null;
  bool get isRefreshFailure => result != null && failure != null;

  BrandsListState copyWith({
    BrandsListStatus? status,
    BrandListQuery? query,
    PaginatedResult<Brand>? result,
    Failure? failure,
    bool clearFailure = false,
  }) => BrandsListState(
    status: status ?? this.status,
    query: query ?? this.query,
    result: result ?? this.result,
    failure: clearFailure ? null : failure ?? this.failure,
  );

  @override
  List<Object?> get props => [status, query, result, failure];
}
