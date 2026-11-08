import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:accounting_software/app/core/access/cubit/access_cubit.dart';
import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/core/routing/go_router_refresh_stream.dart';
import 'package:accounting_software/app/routing/not_found_screen.dart';
import 'package:accounting_software/app/routing/route_guards.dart';
import 'package:accounting_software/app/core/routing/route_transitions.dart';
import 'package:accounting_software/app/core/storage/shared_preferences/app_settings_manager.dart';
import 'package:accounting_software/app/core/routing/app_router_observer.dart';
import 'package:accounting_software/app/features/auth/domain/session/session_gate.dart';
import 'package:accounting_software/app/features/auth/presentation/cubit/auth_flow/auth_flow_cubit.dart';
import 'package:accounting_software/app/features/auth/presentation/cubit/profile/profile_cubit.dart';
import 'package:accounting_software/app/features/auth/presentation/cubit/session/session_cubit.dart';
import 'package:accounting_software/app/features/auth/presentation/pages/forgot_password/forgot_password_screen.dart';
import 'package:accounting_software/app/features/auth/presentation/pages/forgot_password/reset_password_screen.dart';
import 'package:accounting_software/app/features/auth/presentation/pages/login/login_screen.dart';
import 'package:accounting_software/app/features/auth/presentation/pages/signup/signup_screen.dart';
import 'package:accounting_software/app/features/auth/presentation/routing/auth_routes.dart';
import 'package:accounting_software/app/features/favorites/presentation/pages/favorite_screen.dart';
import 'package:accounting_software/app/features/favorites/presentation/routing/favorites_routes.dart';
import 'package:accounting_software/app/features/home/presentation/cubit/home_cubit.dart';
import 'package:accounting_software/app/features/home/presentation/pages/home_screen.dart';
import 'package:accounting_software/app/features/home/presentation/routing/home_routes.dart';
import 'package:accounting_software/app/features/on_boarding/presentation/cubit/on_boarding_cubit.dart';
import 'package:accounting_software/app/features/on_boarding/presentation/pages/on_boarding_screen.dart';
import 'package:accounting_software/app/features/on_boarding/presentation/routing/on_boarding_routes.dart';
import 'package:accounting_software/app/features/profile/presentation/pages/profile_screen.dart';
import 'package:accounting_software/app/features/profile/presentation/routing/profile_routes.dart';
import 'package:accounting_software/app/features/splash/presentation/cubit/splash_cubit.dart';
import 'package:accounting_software/app/features/splash/presentation/cubit/splash_state.dart';
import 'package:accounting_software/app/features/splash/presentation/pages/splash_screen.dart';
import 'package:accounting_software/app/features/splash/presentation/routing/splash_routes.dart';
import 'package:accounting_software/app/shell/app_shell.dart';

class AppRouter {
  /// The router sees the session only through its contract.
  static final SessionGate session = sl<SessionGate>();
  static final AppSettingsManager settings = sl<AppSettingsManager>();
  static final SplashCubit splashCubit = sl<SplashCubit>();
  static final AccessCubit accessCubit = sl<AccessCubit>();

  static final GoRouter router = GoRouter(
    initialLocation: SplashRoutes.splash.path,

    routes: _buildRoutes(),
    redirect: _redirect,
    observers: [MyNavObserver()],

    refreshListenable: GoRouterRefreshStream([
      session.changes,
      splashCubit.stream,
      accessCubit.stream, // أعد تقييم حراس الصلاحيات عند تغيّر الدور
    ]),
    errorPageBuilder: (context, state) {
      return RouteTransitions.fade(
        context,
        state,
        NotFoundScreen(location: state.uri.toString()),
      );
    },
  );

  static List<RouteBase> _buildRoutes() {
    return [
      /// ─────────────────────────────────────────
      /// Splash
      /// ─────────────────────────────────────────
      GoRoute(
        path: SplashRoutes.splash.path,
        name: SplashRoutes.splash.name,
        pageBuilder: (context, state) => RouteTransitions.fade(
          context,
          state,
          BlocProvider.value(
            value: splashCubit,
            child: const SplashScreen(),
          ),
        ),
      ),

      /// ─────────────────────────────────────────
      /// Onboarding
      /// ─────────────────────────────────────────
      GoRoute(
        path: OnBoardingRoutes.onboarding.path,
        name: OnBoardingRoutes.onboarding.name,
        pageBuilder: (context, state) => RouteTransitions.slide(
          context,
          state,
          BlocProvider(
            create: (context) => sl<OnBoardingCubit>(),
            child: OnBoardingScreen(),
          ),
        ),
      ),

      // ─────────────────────────────────────────
      // ثانياً: صفحات المصادقة
      // ─────────────────────────────────────────

      /// ─────────────────────────────────────────
      /// Login
      /// ─────────────────────────────────────────
      GoRoute(
        path: AuthRoutes.login.path,
        name: AuthRoutes.login.name,
        pageBuilder: (context, state) => RouteTransitions.fade(
          context,
          state,
          _withAuthFlow(const LoginScreen()),
        ),
      ),

      /// ─────────────────────────────────────────
      /// Register
      /// ─────────────────────────────────────────
      GoRoute(
        path: AuthRoutes.register.path,
        name: AuthRoutes.register.name,
        pageBuilder: (context, state) => RouteTransitions.slide(
          context,
          state,
          _withAuthFlow(const SignUpScreen()),
        ),
      ),

      /// ─────────────────────────────────────────
      /// Password recovery: e-mail → code + new password
      /// ─────────────────────────────────────────
      GoRoute(
        path: AuthRoutes.forgotPassword.path,
        name: AuthRoutes.forgotPassword.name,
        pageBuilder: (context, state) => RouteTransitions.slide(
          context,
          state,
          _withAuthFlow(const ForgotPasswordScreen()),
        ),
      ),
      GoRoute(
        path: AuthRoutes.resetPassword.path,
        name: AuthRoutes.resetPassword.name,
        // Opened without an e-mail (deep link, refresh): start over.
        redirect: (context, state) =>
            (state.uri.queryParameters['email'] ?? '').isEmpty
            ? AuthRoutes.forgotPassword.path
            : null,
        pageBuilder: (context, state) => RouteTransitions.slide(
          context,
          state,
          _withAuthFlow(
            ResetPasswordScreen(email: state.uri.queryParameters['email']!),
          ),
        ),
      ),

      /// ─────────────────────────────────────────
      /// MAIN APP (adaptive shell: bottom bar / rail / sidebar)
      /// ─────────────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },

        branches: [
          /// ───────── HOME ─────────
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: HomeRoutes.home.path,
                name: HomeRoutes.home.name,
                pageBuilder: (context, state) => NoTransitionPage(
                  child: MultiBlocProvider(
                    providers: [
                      BlocProvider<SessionCubit>.value(
                        value: sl<SessionCubit>(),
                      ),
                      BlocProvider<HomeCubit>(
                        create: (_) => sl<HomeCubit>()..load(),
                      ),
                    ],
                    child: const HomeScreen(),
                  ),
                ),
              ),
            ],
          ),

          /// ───────── FAVORITES ─────────
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: FavoritesRoutes.favorites.path,
                name: FavoritesRoutes.favorites.name,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: FavoriteScreen()),
              ),
            ],
          ),

          /// ───────── PROFILE ─────────
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: ProfileRoutes.profile.path,
                name: ProfileRoutes.profile.name,
                pageBuilder: (context, state) =>
                    NoTransitionPage(child: _withSession(const ProfileScreen())),
              ),
            ],
          ),
        ],
      ),
    ];
  }

  /// Auth pages get their own [AuthFlowCubit] (a new one per page, closed with
  /// it), so loading state never leaks between pages.
  static Widget _withAuthFlow(Widget page) =>
      BlocProvider<AuthFlowCubit>(
        create: (_) => sl<AuthFlowCubit>(),
        child: page,
      );

  /// The profile page: the app-wide session (`.value`, never closed with the
  /// page) plus its own [ProfileCubit].
  static Widget _withSession(Widget page) => MultiBlocProvider(
    providers: [
      BlocProvider<SessionCubit>.value(value: sl<SessionCubit>()),
      BlocProvider<ProfileCubit>(create: (_) => sl<ProfileCubit>()),
    ],
    child: page,
  );

  static Future<String?> _redirect(
    BuildContext context,
    GoRouterState state,
  ) async => resolveRedirect(
    location: state.matchedLocation,
    splashDone: splashCubit.state is SplashDone,
    onboarded: await settings.isOnboarded(),
    session: session.current,
  );
}
