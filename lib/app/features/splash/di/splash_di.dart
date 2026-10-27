import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/features/splash/presentation/cubit/splash_cubit.dart';


void initSplashDI() {
  // splash Feature
  // cubit
  // Singleton: the router guards and the splash screen must share one instance.
  sl.registerLazySingleton(() => SplashCubit());
}
