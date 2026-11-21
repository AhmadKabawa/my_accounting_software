import 'package:equatable/equatable.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand_stats.dart';

sealed class BrandStatsState extends Equatable {
  const BrandStatsState();

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
  const BrandStatsLoaded(this.stats);

  final BrandStats stats;

  @override
  List<Object?> get props => [stats];
}

final class BrandStatsFailed extends BrandStatsState {
  const BrandStatsFailed(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
