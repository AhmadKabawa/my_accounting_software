import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/features/catalog/domain/entity/brand_list_query.dart';
import 'package:accounting_software/app/features/catalog/domain/entity/brand_stats.dart';
import 'package:accounting_software/app/features/catalog/domain/usecase/get_brands_use_case.dart';

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

/// Loads catalog-wide counts independently from the filtered brands list.
class BrandStatsCubit extends Cubit<BrandStatsState> {
  BrandStatsCubit({required GetBrandsUseCase getBrands})
    : _getBrands = getBrands,
      super(const BrandStatsInitial());

  final GetBrandsUseCase _getBrands;
  int _requestVersion = 0;

  Future<void> load() async {
    final version = ++_requestVersion;
    if (state is! BrandStatsLoaded) {
      emit(const BrandStatsLoading());
    }

    final results = await Future.wait([
      _getBrands(const BrandListQuery(page: 1, pageSize: 1)),
      _getBrands(
        const BrandListQuery(
          status: BrandStatusFilter.active,
          page: 1,
          pageSize: 1,
        ),
      ),
    ]);
    if (isClosed || version != _requestVersion) return;

    Failure? failure;
    int? total;
    int? active;
    results[0].fold(
      (value) => failure = value,
      (page) => total = page.totalCount,
    );
    results[1].fold(
      (value) => failure ??= value,
      (page) => active = page.totalCount,
    );

    if (failure != null) {
      emit(BrandStatsFailed(failure!));
      return;
    }

    final totalCount = total!;
    final activeCount = active!;
    emit(
      BrandStatsLoaded(
        BrandStats(
          total: totalCount,
          active: activeCount,
          inactive: totalCount - activeCount,
        ),
      ),
    );
  }

  Future<void> refresh() => load();

  @override
  Future<void> close() {
    _requestVersion++;
    return super.close();
  }
}
