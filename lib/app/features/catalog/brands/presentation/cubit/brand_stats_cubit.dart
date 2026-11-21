import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/base/use_case.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand_stats.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/usecase/get_brand_stats_use_case.dart';

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

/// Owns the presentation lifecycle for catalog-wide brand statistics.
class BrandStatsCubit extends Cubit<BrandStatsState> {
  BrandStatsCubit({required GetBrandStatsUseCase getBrandStats})
    : _getBrandStats = getBrandStats,
      super(const BrandStatsInitial());

  final GetBrandStatsUseCase _getBrandStats;
  int _requestVersion = 0;

  Future<void> load() async {
    final version = ++_requestVersion;
    if (state is! BrandStatsLoaded) {
      emit(const BrandStatsLoading());
    }

    final result = await _getBrandStats(NoParams());
    if (isClosed || version != _requestVersion) return;

    result.fold(
      (failure) => emit(BrandStatsFailed(failure)),
      (stats) => emit(BrandStatsLoaded(stats)),
    );
  }

  Future<void> refresh() => load();

  @override
  Future<void> close() {
    _requestVersion++;
    return super.close();
  }
}
