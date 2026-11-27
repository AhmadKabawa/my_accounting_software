import 'package:accounting_software/app/core/presentation/state_management/base_cubit.dart';
import 'package:accounting_software/app/core/foundation/base/use_case.dart';
import 'package:accounting_software/app/features/catalog/genders/domain/usecase/get_gender_stats_use_case.dart';
import 'package:accounting_software/app/features/catalog/genders/presentation/cubit/gender_stats/gender_stats_state.dart';

class GenderStatsCubit extends BaseCubit<GenderStatsState, Never> {
  GenderStatsCubit({required GetGenderStatsUseCase getStats})
    : _getStats = getStats,
      super(const GenderStatsState());
  final GetGenderStatsUseCase _getStats;
  int _version = 0;
  Future<void> load() async {
    if (isClosed) return;
    final v = ++_version;
    if (state.stats == null)
      emit(
        state.copyWith(status: GenderStatsStatus.loading, clearFailure: true),
      );
    final result = await _getStats(NoParams());
    if (isClosed || v != _version) return;
    result.fold(
      (f) => emit(state.copyWith(status: GenderStatsStatus.failed, failure: f)),
      (s) => emit(state.copyWith(status: GenderStatsStatus.ready, stats: s)),
    );
  }

  Future<void> refresh() => load();
  @override
  Future<void> close() {
    _version++;
    return super.close();
  }
}
