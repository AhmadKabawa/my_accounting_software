import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/core/foundation/base/use_case.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/flash_messages.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/message_view_widgets.dart';
import 'package:accounting_software/app/features/home/domain/usecase/get_home_summary_usecase.dart';
import 'package:accounting_software/app/features/home/presentation/cubit/home_state.dart';
import 'package:accounting_software/app/features/home/presentation/localization/home_keys.dart';
import 'package:accounting_software/app/features/home/presentation/model/quick_action.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({
    required GetHomeSummaryUseCase getSummary,
    required FlashMessages flash,
  }) : _getSummary = getSummary,
       _flash = flash,
       super(const HomeLoading());

  final GetHomeSummaryUseCase _getSummary;
  final FlashMessages _flash;

  Future<void> load() async {
    emit(const HomeLoading());
    final result = await _getSummary(NoParams());
    if (isClosed) return;
    result.fold(
      (failure) => emit(HomeFailed(failure.messageKey)),
      (summary) => emit(HomeLoaded(summary)),
    );
  }

  /// A quick action was tapped. The target modules do not exist yet, so say
  /// so instead of doing nothing; [action] is kept for the future navigation.
  void openAction(QuickAction action) {
    _flash.post(HomeKeys.comingSoon, MessageType.info);
  }
}
