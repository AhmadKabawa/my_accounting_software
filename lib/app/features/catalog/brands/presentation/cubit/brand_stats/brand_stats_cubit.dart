import 'package:accounting_software/app/core/presentation/state_management/base_cubit.dart';
import 'package:accounting_software/app/core/foundation/base/use_case.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/flash_messages.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/message_view_widgets.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/usecase/get_brand_stats_use_case.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/cubit/brand_stats/brand_stats_state.dart';

/// Owns the presentation lifecycle for catalog-wide brand statistics.
class BrandStatsCubit extends BaseCubit<BrandStatsState, void> {
  BrandStatsCubit({
    required GetBrandStatsUseCase getBrandStats,
    required FlashMessages flashMessages,
  }) : _getBrandStats = getBrandStats,
       _flashMessages = flashMessages,
       super(const BrandStatsInitial());

  final GetBrandStatsUseCase _getBrandStats;
  final FlashMessages _flashMessages;
  int _requestVersion = 0;

  Future<void> load() async {
    final version = ++_requestVersion;
    final previous = state.stats;
    if (previous == null) emit(const BrandStatsLoading());

    final result = await _getBrandStats(NoParams());
    if (isClosed || version != _requestVersion) return;

    result.fold(
      (failure) {
        _flashMessages.post(failure.messageKey, MessageType.error);
        emit(
          previous == null
              ? BrandStatsFailed(failure)
              : BrandStatsRefreshFailed(previous, failure),
        );
      },
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
