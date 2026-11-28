import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:accounting_software/app/core/access/cubit/access_cubit.dart';
import 'package:accounting_software/app/core/platform/platform_capabilities.dart';
import 'package:accounting_software/app/core/routing/unsaved_changes_guard.dart';
import 'package:accounting_software/app/core/foundation/config/app_config.dart';
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
import 'package:accounting_software/app/features/auth/presentation/pages/change_password/force_password_change_screen.dart';
import 'package:accounting_software/app/features/auth/presentation/cubit/force_password/force_password_change_cubit.dart';
import 'package:accounting_software/app/features/auth/presentation/pages/signup/signup_screen.dart';
import 'package:accounting_software/app/features/auth/presentation/routing/auth_routes.dart';
import 'package:accounting_software/app/features/home/presentation/pages/home_screen.dart';
import 'package:accounting_software/app/features/home/presentation/routing/home_routes.dart';
import 'package:accounting_software/app/routing/route_registry.dart';
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
import 'package:accounting_software/app/core/presentation/widgets/app_menu/app_menu.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/features/auth/presentation/localization/auth_keys.dart';
import 'package:accounting_software/app/features/auth/presentation/pages/select_branch/select_branch_screen.dart';
import 'package:accounting_software/app/features/profile/presentation/localization/profile_keys.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/pages/brands_screen.dart';
import 'package:accounting_software/app/features/catalog/presentation/pages/catalog_hub_screen.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/routing/brands_routes.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/pages/colors_screen.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/routing/colors_routes.dart';
import 'package:accounting_software/app/features/catalog/tags/presentation/routing/tags_routes.dart';
import 'package:accounting_software/app/features/catalog/tags/presentation/pages/tags_screen.dart';
import 'package:accounting_software/app/features/catalog/sports/presentation/routing/sports_routes.dart';
import 'package:accounting_software/app/features/catalog/genders/presentation/routing/genders_routes.dart';
import 'package:accounting_software/app/features/catalog/genders/presentation/pages/genders_screen.dart';
import 'package:accounting_software/app/features/catalog/age_groups/presentation/routing/age_groups_routes.dart';
import 'package:accounting_software/app/features/catalog/age_groups/presentation/pages/age_groups_screen.dart';
import 'package:accounting_software/app/features/catalog/sports/presentation/pages/sports_screen.dart';
import 'package:accounting_software/app/features/catalog/presentation/routing/catalog_routes.dart';
import 'package:accounting_software/app/features/catalog/categories/presentation/routing/categories_routes.dart';
import 'package:accounting_software/app/features/catalog/categories/presentation/categories_list_page.dart';
import 'package:accounting_software/app/features/catalog/product_types/presentation/pages/product_types_screen.dart';
import 'package:accounting_software/app/features/catalog/product_types/presentation/pages/product_type_details_screen.dart';
import 'package:accounting_software/app/features/catalog/product_types/presentation/routing/product_types_routes.dart';
import 'package:accounting_software/app/features/catalog/units/presentation/pages/units_screen.dart';
import 'package:accounting_software/app/features/catalog/units/presentation/routing/units_routes.dart';
import 'package:accounting_software/app/features/catalog/option_sets/presentation/pages/option_sets_screen.dart';
import 'package:accounting_software/app/features/catalog/option_sets/presentation/routing/option_sets_routes.dart';
import 'package:accounting_software/app/features/catalog/attributes/presentation/pages/attributes_screen.dart';
import 'package:accounting_software/app/features/catalog/attributes/presentation/routing/attributes_routes.dart';
import 'package:accounting_software/app/features/catalog/size_systems/systems/presentation/pages/size_systems_screen.dart';
import 'package:accounting_software/app/features/catalog/size_systems/sizes/presentation/pages/sizes_screen.dart';
import 'package:accounting_software/app/features/catalog/size_systems/presentation/routing/size_systems_routes.dart';
import 'package:accounting_software/app/features/catalog/size_systems/groups/presentation/pages/size_groups_screen.dart';
import 'package:accounting_software/app/features/catalog/materials/presentation/routing/materials_routes.dart';
import 'package:accounting_software/app/features/catalog/materials/presentation/pages/materials_screen.dart';
import 'package:accounting_software/app/features/catalog/fabric_types/presentation/routing/fabric_types_routes.dart';
import 'package:accounting_software/app/features/catalog/fabric_types/presentation/pages/fabric_types_screen.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/presentation/routing/care_instructions_routes.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/presentation/pages/care_instructions_screen.dart';
import 'package:accounting_software/app/features/catalog/seasons/presentation/routing/seasons_routes.dart';
import 'package:accounting_software/app/features/catalog/seasons/presentation/pages/seasons_screen.dart';
import 'package:accounting_software/app/features/catalog/collections/presentation/routing/collections_routes.dart';
import 'package:accounting_software/app/features/catalog/collections/presentation/pages/collections_screen.dart';

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
      /// ─────────────────────────────────────────
      /// Splash
      /// ─────────────────────────────────────────
      GoRoute(
        path: SplashRoutes.splash.path,
        name: SplashRoutes.splash.name,
        pageBuilder: (context, state) => RouteTransitions.fade(
          context,
          state,
          BlocProvider.value(value: splashCubit, child: const SplashScreen()),
        ),
      ),

      /// ─────────────────────────────────────────
      /// Onboarding
      /// ─────────────────────────────────────────
      if (AppConfig.onboardingEnabled)
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
      /// Forced password change (AUTH-02)
      GoRoute(
        path: AuthRoutes.changePassword.path,
        name: AuthRoutes.changePassword.name,
        pageBuilder: (context, state) => RouteTransitions.fade(
          context,
          state,
          MultiBlocProvider(
            providers: [
              BlocProvider<SessionCubit>.value(value: sl<SessionCubit>()),
              BlocProvider<ForcePasswordChangeCubit>(
                create: (_) => sl<ForcePasswordChangeCubit>(),
              ),
            ],
            child: const ForcePasswordChangeScreen(),
          ),
        ),
      ),

      /// Select branch (AUTH-03)
      /// ─────────────────────────────────────────
      GoRoute(
        path: AuthRoutes.selectBranch.path,
        name: AuthRoutes.selectBranch.name,
        pageBuilder: (context, state) => RouteTransitions.fade(
          context,
          state,
          BlocProvider<AccessCubit>.value(
            value: accessCubit,
            child: const SelectBranchScreen(),
          ),
        ),
      ),

      /// ─────────────────────────────────────────
      /// Register
      /// ─────────────────────────────────────────
      if (AppConfig.signupEnabled)
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
      if (AppConfig.forgotPasswordEnabled)
        GoRoute(
          path: AuthRoutes.forgotPassword.path,
          name: AuthRoutes.forgotPassword.name,
          pageBuilder: (context, state) => RouteTransitions.slide(
            context,
            state,
            _withAuthFlow(const ForgotPasswordScreen()),
          ),
        ),
      if (AppConfig.forgotPasswordEnabled)
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
          /// ───────── HOME ─────────
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: HomeRoutes.home.path,
                name: HomeRoutes.home.name,
                pageBuilder: (context, state) => NoTransitionPage(
                  child: HomeScreen(registeredRoutes: allRoutes),
                ),
              ),
            ],
          ),

          /// ───────── CATALOG ─────────
          StatefulShellBranch(
            initialLocation: CatalogRoutes.hub.path,
            routes: [
              GoRoute(
                path: CatalogRoutes.hub.path,
                name: CatalogRoutes.hub.name,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: CatalogHubScreen()),
              ),
              GoRoute(
                path: CatalogRoutes.masterData.path,
                name: CatalogRoutes.masterData.name,
                redirect: (context, state) => catalogMasterDataRedirect(),
              ),
              GoRoute(
                path: BrandsRoutes.brands.path,
                name: BrandsRoutes.brands.name,
                pageBuilder: (context, state) =>
                    NoTransitionPage(child: const BrandsScreen()),
              ),
              GoRoute(
                path: UnitsRoutes.units.path,
                name: UnitsRoutes.units.name,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: UnitsScreen()),
              ),
              GoRoute(
                path: OptionSetsRoutes.optionSets.path,
                name: OptionSetsRoutes.optionSets.name,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: OptionSetsScreen()),
              ),
              GoRoute(
                path: AttributesRoutes.attributes.path,
                name: AttributesRoutes.attributes.name,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: AttributesScreen()),
              ),
              GoRoute(
                path: SizeSystemsRoutes.sizeSystems.path,
                name: SizeSystemsRoutes.sizeSystems.name,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: SizeSystemsScreen()),
              ),
              GoRoute(
                path: SizeSystemsRoutes.groupsPath,
                name: SizeSystemsRoutes.groupsName,
                pageBuilder: (context, state) {
                  final systemId = int.tryParse(
                    state.pathParameters['systemId'] ?? '',
                  );
                  final extra = state.extra;
                  return NoTransitionPage(
                    child: systemId == null
                        ? NotFoundScreen(location: state.uri.toString())
                        : SizeGroupsScreen(
                            systemId: systemId,
                            labels: extra is SizeRouteContext ? extra : null,
                          ),
                  );
                },
              ),
              GoRoute(
                path: SizeSystemsRoutes.sizesPath,
                name: SizeSystemsRoutes.sizesName,
                pageBuilder: (context, state) {
                  final systemId = int.tryParse(
                    state.pathParameters['systemId'] ?? '',
                  );
                  final groupId = int.tryParse(
                    state.pathParameters['groupId'] ?? '',
                  );
                  final extra = state.extra;
                  return NoTransitionPage(
                    child: systemId == null || groupId == null
                        ? NotFoundScreen(location: state.uri.toString())
                        : SizesScreen(
                            systemId: systemId,
                            groupId: groupId,
                            labels: extra is SizeRouteContext ? extra : null,
                          ),
                  );
                },
              ),
              GoRoute(
                path: CategoriesRoutes.categories.path,
                name: CategoriesRoutes.categories.name,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: CategoriesListPage()),
              ),
              GoRoute(
                path: ProductTypesRoutes.productTypes.path,
                name: ProductTypesRoutes.productTypes.name,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: ProductTypesScreen()),
              ),
              GoRoute(
                path: ProductTypesRoutes.detailsPath,
                name: 'catalog.productTypeDetails',
                pageBuilder: (context, state) {
                  final id = int.tryParse(state.pathParameters['id'] ?? '');
                  return NoTransitionPage(
                    child: id == null
                        ? NotFoundScreen(location: state.uri.toString())
                        : ProductTypeDetailsScreen(productTypeId: id),
                  );
                },
              ),
              GoRoute(
                path: ColorsRoutes.colors.path,
                name: ColorsRoutes.colors.name,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: ColorsScreen()),
              ),
              GoRoute(
                path: TagsRoutes.tags.path,
                name: TagsRoutes.tags.name,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: TagsScreen()),
              ),
              GoRoute(
                path: GendersRoutes.genders.path,
                name: GendersRoutes.genders.name,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: GendersScreen()),
              ),
              GoRoute(
                path: AgeGroupsRoutes.ageGroups.path,
                name: AgeGroupsRoutes.ageGroups.name,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: AgeGroupsScreen()),
              ),
              GoRoute(
                path: MaterialsRoutes.materials.path,
                name: MaterialsRoutes.materials.name,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: MaterialsScreen()),
              ),
              GoRoute(
                path: FabricTypesRoutes.fabricTypes.path,
                name: FabricTypesRoutes.fabricTypes.name,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: FabricTypesScreen()),
              ),
              GoRoute(
                path: CareInstructionsRoutes.careInstructions.path,
                name: CareInstructionsRoutes.careInstructions.name,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: CareInstructionsScreen()),
              ),
              GoRoute(
                path: SeasonsRoutes.seasons.path,
                name: SeasonsRoutes.seasons.name,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: SeasonsScreen()),
              ),
              GoRoute(
                path: CollectionsRoutes.collections.path,
                name: CollectionsRoutes.collections.name,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: CollectionsScreen()),
              ),
              GoRoute(
                path: SportsRoutes.sports.path,
                name: SportsRoutes.sports.name,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: SportsScreen()),
              ),
            ],
          ),

          /// ───────── PROFILE ─────────
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: ProfileRoutes.profile.path,
                name: ProfileRoutes.profile.name,
                pageBuilder: (context, state) => NoTransitionPage(
                  child: _withSession(const ProfileScreen()),
                ),
              ),
            ],
          ),
        ],
      ),
    ];
  }

  /// Auth pages get their own [AuthFlowCubit] (a new one per page, closed with
  /// it), so loading state never leaks between pages.
  static Widget _withAuthFlow(Widget page) => BlocProvider<AuthFlowCubit>(
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
