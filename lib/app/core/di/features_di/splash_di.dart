import 'package:get_it/get_it.dart';
import 'package:accounting_software/app/features/splash/presentation/cubit/splash_cubit.dart';

final sl = GetIt.instance;

void initSplashDI() {
  // splash Feature
  // cubit
  // Singleton: the router guards and the splash screen must share one instance.
  sl.registerLazySingleton(() => SplashCubit());
}
