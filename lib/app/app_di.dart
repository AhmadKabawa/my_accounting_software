import 'package:accounting_software/app/core/access/di/access_di.dart';
import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/features/auth/data/auth_endpoints.dart';
import 'package:accounting_software/app/features/auth/di/auth_di.dart';
import 'package:accounting_software/app/features/auth/domain/session/session_gate.dart';
import 'package:accounting_software/app/features/auth/presentation/cubit/session/session_cubit.dart';
import 'package:accounting_software/app/features/home/di/home_di.dart';
import 'package:accounting_software/app/features/on_boarding/di/on_boarding_di.dart';
import 'package:accounting_software/app/features/splash/di/splash_di.dart';

/// Composition root: infrastructure first, then core access and features.
Future<void> initServiceLocator() async {
  await initCoreDI(refreshEndpoint: AuthEndpoints.token);
  initAccessDI();
  await initAuthStorage();
  initAuthDI();
  initOnBoardingDI();
  initSplashDI(checkSession: sl<SessionCubit>().checkAuthentication);
  initHomeDI();
}
