import 'package:accounting_software/app/core/access/cubit/access_cubit.dart';
import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/features/auth/di/auth_di.dart';
import 'package:accounting_software/app/features/auth/domain/session/session_gate.dart';
import 'package:accounting_software/app/features/auth/presentation/cubit/session/session_cubit.dart';
import 'package:accounting_software/app/features/home/di/home_di.dart';
import 'package:accounting_software/app/features/on_boarding/di/on_boarding_di.dart';
import 'package:accounting_software/app/features/splash/di/splash_di.dart';

/// Composition root: the only place that wires core and every feature together.
///
/// Order matters:
///  1. core first (everything depends on it);
///  2. auth before splash — the splash runs the session check from auth
///     (`initSplashDI` asserts this);
///  3. the remaining features have no ordering requirements between them.
Future<void> initServiceLocator() async {
  await initCoreDI();
  await initAuthStorage();
  initAuthDI();
  initOnBoardingDI();
  initSplashDI(checkSession: sl<SessionCubit>().checkAuthentication);
  initHomeDI();

  // لا تبقى صلاحيات المستخدم السابق بعد الخروج أو انتهاء الجلسة.
  // الاشتراك يعيش بعمر التطبيق (الـ cubits singletons).
  sl<SessionGate>().changes
      .where((status) => status is SessionUnauthenticated)
      .listen((_) => sl<AccessCubit>().clear());
}
