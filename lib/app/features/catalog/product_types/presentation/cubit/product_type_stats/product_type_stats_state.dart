import 'package:equatable/equatable.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/entity/product_type_stats.dart';

sealed class ProductTypeStatsState extends Equatable {
  const ProductTypeStatsState();

  ProductTypeStats? get stats => null;

  @override
  List<Object?> get props => [];
}

final class ProductTypeStatsInitial extends ProductTypeStatsState {
  const ProductTypeStatsInitial();
}

final class ProductTypeStatsLoading extends ProductTypeStatsState {
  const ProductTypeStatsLoading();
}

final class ProductTypeStatsLoaded extends ProductTypeStatsState {
  const ProductTypeStatsLoaded(this.value);

  final ProductTypeStats value;

  @override
  ProductTypeStats get stats => value;

  @override
  List<Object?> get props => [value];
}

final class ProductTypeStatsFailed extends ProductTypeStatsState {
  const ProductTypeStatsFailed(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

final class ProductTypeStatsRefreshFailed extends ProductTypeStatsState {
  const ProductTypeStatsRefreshFailed(this.value, this.failure);

  final ProductTypeStats value;
  final Failure failure;

  @override
  ProductTypeStats get stats => value;

  @override
  List<Object?> get props => [value, failure];
}
