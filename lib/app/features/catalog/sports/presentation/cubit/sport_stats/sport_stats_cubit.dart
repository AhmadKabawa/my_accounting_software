import 'package:accounting_software/app/core/presentation/state_management/base_cubit.dart';
import 'package:accounting_software/app/core/foundation/base/use_case.dart';
import 'package:accounting_software/app/features/catalog/sports/domain/usecase/get_sport_stats_use_case.dart';
import 'package:accounting_software/app/features/catalog/sports/presentation/cubit/sport_stats/sport_stats_state.dart';

class SportStatsCubit extends BaseCubit<SportStatsState, Never> {
  SportStatsCubit({required GetSportStatsUseCase getSportStats})
    : _getSportStats = getSportStats,
      super(const SportStatsState());

  final GetSportStatsUseCase _getSportStats;
  int _requestVersion = 0;

  Future<void> load() async {
    if (isClosed) return;
    final version = ++_requestVersion;
    if (state.stats == null) {
      emit(
        state.copyWith(status: SportStatsStatus.loading, clearFailure: true),
      );
    }
    final result = await _getSportStats(NoParams());
    if (isClosed || version != _requestVersion) return;
    result.fold(
      (failure) => emit(
        state.copyWith(status: SportStatsStatus.failed, failure: failure),
      ),
      (stats) =>
          emit(state.copyWith(status: SportStatsStatus.ready, stats: stats)),
    );
  }

  Future<void> refresh() => load();

  @override
  Future<void> close() {
    _requestVersion++;
    return super.close();
  }
}
