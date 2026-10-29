import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/features/auth/di/auth_di.dart';
import 'package:accounting_software/app/features/home/di/home_di.dart';
import 'package:accounting_software/app/features/on_boarding/di/on_boarding_di.dart';
import 'package:accounting_software/app/features/splash/di/splash_di.dart';
import 'package:accounting_software/app/main_navigation_bar/di/navigation_bar_di.dart';

/// Composition root: the only place that wires core and every feature together.
///
/// Order matters:
///  1. core first (everything depends on it);
///  2. auth before splash — SplashCubit is built from AuthCubit
///     (`initSplashDI` asserts this);
///  3. the remaining features have no ordering requirements between them.
Future<void> initServiceLocator() async {
  await initCoreDI();
  await initAuthDI();
  initOnBoardingDI();
  initSplashDI();
  initNavigationBarDI();
  initHomeDI();
}
