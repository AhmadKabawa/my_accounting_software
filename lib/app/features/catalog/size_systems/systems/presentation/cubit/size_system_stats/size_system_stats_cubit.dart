import 'package:accounting_software/app/core/foundation/base/use_case.dart';
import 'package:accounting_software/app/core/presentation/state_management/base_cubit.dart';
import 'package:accounting_software/app/features/catalog/size_systems/systems/domain/usecase/size_systems_use_cases.dart';
import 'package:accounting_software/app/features/catalog/size_systems/systems/presentation/cubit/size_system_stats/size_system_stats_state.dart';

class SizeSystemStatsCubit extends BaseCubit<SizeSystemStatsState, Never> {
  SizeSystemStatsCubit({required GetSizeSystemStatsUseCase getStats})
    : _getStats = getStats,
      super(const SizeSystemStatsState());

  final GetSizeSystemStatsUseCase _getStats;
  int _version = 0;

  Future<void> load() async {
    if (isClosed) return;
    final version = ++_version;
    if (state.stats == null) {
      emit(
        state.copyWith(
          status: SizeSystemStatsStatus.loading,
          clearFailure: true,
        ),
      );
    }
    final result = await _getStats(NoParams());
    if (isClosed || version != _version) return;
    result.fold(
      (failure) => emit(
        state.copyWith(status: SizeSystemStatsStatus.failed, failure: failure),
      ),
      (stats) => emit(
        state.copyWith(status: SizeSystemStatsStatus.ready, stats: stats),
      ),
    );
  }

  Future<void> refresh() => load();

  @override
  Future<void> close() {
    _version++;
    return super.close();
  }
}
