import 'package:accounting_software/app/core/foundation/base_mixin/base/base_cubit/base_side_effects/base_cubit.dart';
import 'package:accounting_software/app/core/services/local_storage/shared_storage/app_settings_manager_sorage.dart';
import 'package:accounting_software/app/features/on_boarding/presentation/cubit/on_boarding_effect.dart';
import 'package:accounting_software/app/features/on_boarding/data/model/on_boarding_model.dart';
import 'package:accounting_software/app/features/on_boarding/presentation/cubit/on_boarding_state.dart';

class OnBoardingCubit extends BaseCubit<OnBoardingState, OnBoardingEffect> {
  final AppSettingsManager _settingsManager;
  OnBoardingCubit({required AppSettingsManager settingsManager})
    : _settingsManager = settingsManager,
      super(OnBoardingState.initial());

  void changePage(int index) {
    emit(state.copyWith(currentIndexPage: index));
  }
  // next button

  void nextPage() {
    final isLastPage = state.currentIndexPage >= onboardingData.length - 1;

    if (!isLastPage) {
      emit(state.copyWith(currentIndexPage: state.currentIndexPage + 1));
      return;
    }

    _completeOnboarding();
  }

  void skipOnboarding() {
    emit(state.copyWith(currentIndexPage: onboardingData.length - 1));
  }

  void _completeOnboarding() {
    _settingsManager.setOnboarded();

    emitEffect(const OnBoardingEffect.navigateHome());
  }
}

extension OnBoardingStateX on OnBoardingState {
  bool isLastPage(int length) => currentIndexPage >= length - 1;
}
