import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/features/splash/presentation/cubit/splash_cubit.dart';

/// [checkSession] is wired by the composition root (`app_di.dart`), so the
/// splash feature imports nothing from auth.
void initSplashDI({required Future<void> Function() checkSession}) {
  // Singleton: the router guards and the splash screen must share one instance.
  sl.registerLazySingleton(() => SplashCubit(checkSession: checkSession));
}
