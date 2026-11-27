import 'package:accounting_software/app/core/foundation/base/use_case.dart';
import 'package:accounting_software/app/core/presentation/state_management/base_cubit.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/usecase/get_attribute_stats_use_case.dart';
import 'package:accounting_software/app/features/catalog/attributes/presentation/cubit/attribute_stats/attribute_stats_state.dart';
class AttributeStatsCubit extends BaseCubit<AttributeStatsState, Never> {
  AttributeStatsCubit({required GetAttributeStatsUseCase getStats}) : _getStats = getStats, super(const AttributeStatsState());
  final GetAttributeStatsUseCase _getStats;
  int _version = 0;
  Future<void> load() async {
    if (isClosed) return;
    final version = ++_version;
    if (state.stats == null) emit(state.copyWith(status: AttributeStatsStatus.loading, clearFailure: true));
    final result = await _getStats(NoParams());
    if (isClosed || version != _version) return;
    result.fold(
      (failure) => emit(state.copyWith(status: AttributeStatsStatus.failed, failure: failure)),
      (stats) => emit(state.copyWith(status: AttributeStatsStatus.ready, stats: stats, clearFailure: true)),
    );
  }
  Future<void> refresh() => load();
  @override
  Future<void> close() { _version++; return super.close(); }
}