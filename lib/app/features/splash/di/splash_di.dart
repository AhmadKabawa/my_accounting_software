import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:accounting_software/app/features/splash/presentation/cubit/splash_cubit.dart';


/// Must run AFTER `initAuthDI()`: the splash cubit is built from [AuthCubit].
void initSplashDI() {
  assert(
    sl.isRegistered<AuthCubit>(),
    'initAuthDI() must run before initSplashDI() (see app_di.dart).',
  );
  // splash Feature
  // cubit
  // Singleton: the router guards and the splash screen must share one instance.
  sl.registerLazySingleton(
    () => SplashCubit(checkSession: sl<AuthCubit>().checkAuthentication),
  );
}
