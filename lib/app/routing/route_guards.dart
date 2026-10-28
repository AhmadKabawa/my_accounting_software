import 'package:accounting_software/app/core/routing/routes.dart';
import 'package:accounting_software/app/features/auth/presentation/cubit/states/auth_states.dart';

/// المسارات المتاحة دون تسجيل دخول. أي مسار آخر محمي افتراضيًا (deny by default).
final Set<String> publicRoutes = {
  AppRoutes.splash.path,
  AppRoutes.onboarding.path,
  AppRoutes.login.path,
  AppRoutes.register.path,
};

final Set<String> _authOnlyEntryRoutes = {
  AppRoutes.login.path,
  AppRoutes.register.path,
};

/// دالة نقية تحدد وجهة التوجيه. تعيد null عند عدم الحاجة لأي توجيه.
///
/// الترتيب: Splash ← Onboarding ← المصادقة. لا يحدث أي توجيه أثناء
/// [AuthChecking] أو [AuthLoading] حتى لا يُطرد المستخدم أثناء عملية جارية.
String? resolveRedirect({
  required String location,
  required bool splashDone,
  required bool onboarded,
  required AuthState authState,
}) {
  final splash = AppRoutes.splash.path;
  final onboarding = AppRoutes.onboarding.path;
  final login = AppRoutes.login.path;
  final home = AppRoutes.home.path;

  if (!splashDone) return location == splash ? null : splash;

  if (authState is AuthChecking || authState is AuthLoading) return null;

  final authenticated = authState is Authenticated;

  if (location == splash) {
    if (!onboarded) return onboarding;
    return authenticated ? home : login;
  }

  if (!onboarded) return location == onboarding ? null : onboarding;

  if (authenticated) {
    return _authOnlyEntryRoutes.contains(location) ? home : null;
  }

  return publicRoutes.contains(location) ? null : login;
}
