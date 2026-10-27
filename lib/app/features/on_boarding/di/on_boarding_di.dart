import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/features/on_boarding/presentation/cubit/on_boarding_cubit.dart';


void initOnBoardingDI() {
  // onBoarding Feature
  // cubit
  sl.registerFactory(() => OnBoardingCubit(settingsManager: sl()));
}
