import 'package:get_it/get_it.dart';
import 'package:accounting_software/app/features/splash/presentation/cubit/splash_cubit.dart';

final sl = GetIt.instance;

void initSplashDI() {
  // splash Feature
  // cubit
  sl.registerFactory(() => SplashCubit());
}
