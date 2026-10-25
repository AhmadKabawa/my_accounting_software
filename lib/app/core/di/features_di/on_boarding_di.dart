import 'package:get_it/get_it.dart';
import 'package:accounting_software/app/features/on_boarding/presentation/cubit/on_boarding_cubit.dart';

final sl = GetIt.instance;

void initOnBoardingDI() {
  // onBoarding Feature
  // cubit
  sl.registerFactory(() => OnBoardingCubit(settingsManager: sl()));
}
