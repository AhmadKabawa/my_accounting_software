import 'package:equatable/equatable.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand_list_query.dart';

sealed class BrandsListState extends Equatable {
  const BrandsListState();
}

final class BrandsListInitial extends BrandsListState {
  const BrandsListInitial();
  @override
  List<Object?> get props => [];
}

final class BrandsListLoading extends BrandsListState {
  const BrandsListLoading();
  @override
  List<Object?> get props => [];
}

final class BrandsListReady extends BrandsListState {
  const BrandsListReady({required this.result, required this.query});
  final PaginatedResult<Brand> result;
  final BrandListQuery query;

  @override
  List<Object?> get props => [result, query];
}

final class BrandsListFailed extends BrandsListState {
  const BrandsListFailed(this.failure);
  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

/// A refresh failed after content was already available. Keep the last
/// successful page so a transient network error does not erase the list.
final class BrandsListRefreshFailed extends BrandsListState {
  const BrandsListRefreshFailed({
    required this.result,
    required this.query,
    required this.failure,
  });

  final PaginatedResult<Brand> result;
  final BrandListQuery query;
  final Failure failure;

  @override
  List<Object?> get props => [result, query, failure];
}
