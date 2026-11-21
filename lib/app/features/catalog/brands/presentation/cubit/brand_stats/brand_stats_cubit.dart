import 'package:accounting_software/app/core/presentation/state_management/base_cubit.dart';
import 'package:accounting_software/app/core/foundation/base/use_case.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/usecase/get_brand_stats_use_case.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/cubit/brand_stats/brand_stats_state.dart';

/// Owns the presentation lifecycle for catalog-wide brand statistics.
class BrandStatsCubit extends BaseCubit<BrandStatsState, void> {
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
