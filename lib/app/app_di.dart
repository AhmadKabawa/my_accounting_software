import 'package:accounting_software/app/core/access/access_cubit.dart';
import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/features/auth/di/auth_di.dart';
import 'package:accounting_software/app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:accounting_software/app/features/auth/presentation/cubit/states/auth_states.dart';
import 'package:accounting_software/app/features/home/di/home_di.dart';
import 'package:accounting_software/app/features/on_boarding/di/on_boarding_di.dart';
import 'package:accounting_software/app/features/splash/di/splash_di.dart';
import 'package:accounting_software/app/main_navigation_bar/di/navigation_bar_di.dart';

/// Composition root: the only place that wires core and every feature together.
Future<void> initServiceLocator() async {
  await initCoreDI();
  await initAuthDI();
  initOnBoardingDI();
  initSplashDI();
  initNavigationBarDI();
  initHomeDI();

  // لا تبقى صلاحيات المستخدم السابق بعد الخروج أو انتهاء الجلسة.
  // الاشتراك يعيش بعمر التطبيق (الـ cubits singletons).
  sl<AuthCubit>().stream
      .where((state) => state is Unauthenticated)
      .listen((_) => sl<AccessCubit>().clear());
}
