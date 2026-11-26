import 'package:accounting_software/app/core/foundation/base/use_case.dart';
import 'package:accounting_software/app/core/presentation/state_management/base_cubit.dart';
import 'package:accounting_software/app/features/catalog/units/domain/usecase/get_unit_stats_use_case.dart';
import 'package:accounting_software/app/features/catalog/units/presentation/cubit/unit_stats/unit_stats_state.dart';

class UnitStatsCubit extends BaseCubit<UnitStatsState, Never> {
  UnitStatsCubit({required GetUnitStatsUseCase getUnitStats})
    : _getUnitStats = getUnitStats,
      super(const UnitStatsState());

  final GetUnitStatsUseCase _getUnitStats;
  int _requestVersion = 0;

  Future<void> load() async {
    if (isClosed) return;
    final version = ++_requestVersion;
    if (state.stats == null) {
      emit(state.copyWith(status: UnitStatsStatus.loading, clearFailure: true));
    }
    final result = await _getUnitStats(NoParams());
    if (isClosed || version != _requestVersion) return;
    result.fold(
      (failure) => emit(state.copyWith(status: UnitStatsStatus.failed, failure: failure)),
      (stats) => emit(state.copyWith(status: UnitStatsStatus.ready, stats: stats, clearFailure: true)),
    );
  }

  Future<void> refresh() => load();

  @override
  Future<void> close() {
    _requestVersion++;
    return super.close();
  }
}
