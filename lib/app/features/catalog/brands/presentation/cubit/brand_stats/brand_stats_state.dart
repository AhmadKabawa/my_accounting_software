import 'package:equatable/equatable.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand_stats.dart';

sealed class BrandStatsState extends Equatable {
  const BrandStatsState();

  BrandStats? get stats => null;

  @override
  List<Object?> get props => [];
}

final class BrandStatsInitial extends BrandStatsState {
  const BrandStatsInitial();
}

final class BrandStatsLoading extends BrandStatsState {
  const BrandStatsLoading();
}

final class BrandStatsLoaded extends BrandStatsState {
  const BrandStatsLoaded(this.value);

  final BrandStats value;

  @override
  BrandStats get stats => value;

  @override
  List<Object?> get props => [value];
}

final class BrandStatsFailed extends BrandStatsState {
  const BrandStatsFailed(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

/// A refresh failure keeps the last successful snapshot visible.
final class BrandStatsRefreshFailed extends BrandStatsState {
  const BrandStatsRefreshFailed(this.value, this.failure);

  final BrandStats value;
  final Failure failure;

  @override
  BrandStats get stats => value;

  @override
  List<Object?> get props => [value, failure];
}
