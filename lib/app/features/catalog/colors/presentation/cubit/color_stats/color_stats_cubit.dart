import 'package:accounting_software/app/core/presentation/state_management/base_cubit.dart';
import 'package:accounting_software/app/core/foundation/base/use_case.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/usecase/get_color_stats_use_case.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/cubit/color_stats/color_stats_state.dart';

class ColorStatsCubit extends BaseCubit<ColorStatsState, Never> {
  ColorStatsCubit({required GetColorStatsUseCase getColorStats})
    : _getColorStats = getColorStats,
      super(const ColorStatsState());

  final GetColorStatsUseCase _getColorStats;
  int _requestVersion = 0;

  Future<void> load() async {
    if (isClosed) return;
    final version = ++_requestVersion;
    if (state.stats == null) {
      emit(
        state.copyWith(status: ColorStatsStatus.loading, clearFailure: true),
      );
    }
    final result = await _getColorStats(NoParams());
    if (isClosed || version != _requestVersion) return;
    result.fold(
      (failure) => emit(
        state.copyWith(status: ColorStatsStatus.failed, failure: failure),
      ),
      (stats) =>
          emit(state.copyWith(status: ColorStatsStatus.ready, stats: stats)),
    );
  }

  Future<void> refresh() => load();

  @override
  Future<void> close() {
    _requestVersion++;
    return super.close();
  }
}
