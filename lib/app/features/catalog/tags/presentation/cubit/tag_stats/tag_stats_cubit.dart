import 'package:accounting_software/app/core/presentation/state_management/base_cubit.dart';
import 'package:accounting_software/app/core/foundation/base/use_case.dart';
import 'package:accounting_software/app/features/catalog/tags/domain/usecase/get_tag_stats_use_case.dart';
import 'package:accounting_software/app/features/catalog/tags/presentation/cubit/tag_stats/tag_stats_state.dart';

class TagStatsCubit extends BaseCubit<TagStatsState, Never> {
  TagStatsCubit({required GetTagStatsUseCase getTagStats})
    : _getTagStats = getTagStats,
      super(const TagStatsState());

  final GetTagStatsUseCase _getTagStats;
  int _requestVersion = 0;

  Future<void> load() async {
    if (isClosed) return;
    final version = ++_requestVersion;
    if (state.stats == null) {
      emit(
        state.copyWith(status: TagStatsStatus.loading, clearFailure: true),
      );
    }
    final result = await _getTagStats(NoParams());
    if (isClosed || version != _requestVersion) return;
    result.fold(
      (failure) => emit(
        state.copyWith(status: TagStatsStatus.failed, failure: failure),
      ),
      (stats) =>
          emit(state.copyWith(status: TagStatsStatus.ready, stats: stats)),
    );
  }

  Future<void> refresh() => load();

  @override
  Future<void> close() {
    _requestVersion++;
    return super.close();
  }
}
