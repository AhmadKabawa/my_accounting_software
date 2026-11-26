import 'package:accounting_software/app/core/foundation/base/use_case.dart';
import 'package:accounting_software/app/core/presentation/state_management/base_cubit.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/usecase/get_option_set_stats_use_case.dart';
import 'package:accounting_software/app/features/catalog/option_sets/presentation/cubit/option_set_stats/option_set_stats_state.dart';

class OptionSetStatsCubit extends BaseCubit<OptionSetStatsState, Never> {
  OptionSetStatsCubit({required GetOptionSetStatsUseCase getStats})
    : _getStats = getStats,
      super(const OptionSetStatsState());

  final GetOptionSetStatsUseCase _getStats;
  int _requestVersion = 0;

  Future<void> load() async {
    if (isClosed) return;
    final version = ++_requestVersion;
    if (state.stats == null) {
      emit(state.copyWith(status: OptionSetStatsStatus.loading, clearFailure: true));
    }
    final result = await _getStats(NoParams());
    if (isClosed || version != _requestVersion) return;
    result.fold(
      (failure) => emit(state.copyWith(status: OptionSetStatsStatus.failed, failure: failure)),
      (stats) => emit(state.copyWith(
        status: OptionSetStatsStatus.ready,
        stats: stats,
        clearFailure: true,
      )),
    );
  }

  Future<void> refresh() => load();

  @override
  Future<void> close() {
    _requestVersion++;
    return super.close();
  }
}
