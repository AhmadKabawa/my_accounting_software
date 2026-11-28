import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:accounting_software/app/core/access/cubit/access_cubit.dart';
import 'package:accounting_software/app/core/platform/platform_capabilities.dart';
import 'package:accounting_software/app/core/routing/unsaved_changes_guard.dart';
import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/core/routing/go_router_refresh_stream.dart';
import 'package:accounting_software/app/core/routing/route_transitions.dart';
import 'package:accounting_software/app/routing/not_found_screen.dart';
import 'package:accounting_software/app/routing/route_guards.dart';
import 'package:accounting_software/app/core/storage/shared_preferences/app_settings_manager.dart';
import 'package:accounting_software/app/core/routing/app_router_observer.dart';
import 'package:accounting_software/app/features/auth/domain/session/session_gate.dart';
import 'package:accounting_software/app/features/catalog/presentation/routing/catalog_go_routes.dart';
import 'package:accounting_software/app/features/splash/presentation/routing/splash_go_routes.dart';
import 'package:accounting_software/app/features/on_boarding/presentation/routing/on_boarding_go_routes.dart';
import 'package:accounting_software/app/features/auth/presentation/routing/auth_go_routes.dart';
import 'package:accounting_software/app/features/access/presentation/routing/access_go_routes.dart';
import 'package:accounting_software/app/features/home/presentation/routing/home_go_routes.dart';
import 'package:accounting_software/app/features/profile/presentation/routing/profile_go_routes.dart';
import 'package:accounting_software/app/features/auth/presentation/cubit/session/session_cubit.dart';
import 'package:accounting_software/app/routing/route_registry.dart';
import 'package:accounting_software/app/features/profile/presentation/routing/profile_routes.dart';
import 'package:accounting_software/app/features/splash/presentation/cubit/splash_cubit.dart';
import 'package:accounting_software/app/features/splash/presentation/cubit/splash_state.dart';
import 'package:accounting_software/app/features/splash/presentation/routing/splash_routes.dart';
import 'package:accounting_software/app/shell/app_shell.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_menu/app_menu.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/features/auth/presentation/localization/auth_keys.dart';
import 'package:accounting_software/app/features/profile/presentation/localization/profile_keys.dart';
import 'package:accounting_software/app/features/catalog/presentation/routing/catalog_routes.dart';

AppMenuEntry buildSignOutMenuEntry({
  required Future<bool> Function() signOut,
}) => AppMenuEntry(
  label: AuthKeys.signOut,
  icon: AppIcons.logout,
  requiresUnsavedChangesCheck: true,
  onSelected: () {},
  onSelectedGuardedAsync: signOut,
);

class AppRouter {
  /// The router sees the session only through its contract.
  static final SessionGate session = sl<SessionGate>();
  static final AppSettingsManager settings = sl<AppSettingsManager>();
  static final UnsavedChangesGuard unsavedChangesGuard = UnsavedChangesGuard();
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
      ...buildSplashGoRoutes(splashCubit: splashCubit),
      ...buildOnBoardingGoRoutes(),
      ...buildAuthGoRoutes(accessCubit: accessCubit),
      ...buildAccessGoRoutes(),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(
            navigationShell: navigationShell,
            supportsCollapsibleSidebar:
                PlatformCapabilities.supportsCollapsibleSidebar,
            settingsManager: settings,
            unsavedChangesGuard: unsavedChangesGuard,
            userMenuEntries: [
              AppMenuEntry(
                label: ProfileKeys.title,
                icon: AppIcons.person,
                onSelected: () => context.go(ProfileRoutes.profile.path),
              ),
              buildSignOutMenuEntry(
                signOut: sl<SessionCubit>().signOutWithResult,
              ),
            ],
          );
        },
        branches: [
          StatefulShellBranch(
            routes: buildHomeGoRoutes(registeredRoutes: allRoutes),
          ),
          StatefulShellBranch(
            initialLocation: CatalogRoutes.hub.path,
            routes: buildCatalogRoutes(
              accessCubit: accessCubit,
              session: session,
            ),
          ),
          StatefulShellBranch(routes: buildProfileGoRoutes()),
        ],
      ),
    ];
  }

  static Future<String?> _redirect(
    BuildContext context,
    GoRouterState state,
  ) async => resolveRedirect(
    location: state.uri.path,
    splashDone: splashCubit.state is SplashDone,
    onboarded: await settings.isOnboarded(),
    session: session.current,
    mustChangePassword:
        session.current is SessionAuthenticated &&
        (session.current as SessionAuthenticated).mustChangePassword,
    branchSelectionRequired: accessCubit.state.needsBranchSelection,
  );
}
