import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/core/routing/go_router_refresh_stream.dart';
import 'package:accounting_software/app/routing/route_guards.dart';
import 'package:accounting_software/app/core/routing/route_transitions.dart';
import 'package:accounting_software/app/core/routing/routes.dart';
import 'package:accounting_software/app/core/services/local_storage/shared_storage/app_settings_manager_sorage.dart';
import 'package:accounting_software/app/core/utils/observer/app_router_observer.dart';
import 'package:accounting_software/app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:accounting_software/app/features/auth/presentation/pages/login/login_screen.dart';
// import 'package:accounting_software/app/features/chat/presentation/pages/chat_screen.dart';
import 'package:accounting_software/app/features/favorites/presentation/pages/favorite_screen.dart';
import 'package:accounting_software/app/features/home/presentation/cubit/home_cubit.dart';
import 'package:accounting_software/app/features/home/presentation/pages/home_screen.dart';
import 'package:accounting_software/app/features/on_boarding/presentation/cubit/on_boarding_cubit.dart';
import 'package:accounting_software/app/features/on_boarding/presentation/pages/on_boarding_screen.dart';
import 'package:accounting_software/app/features/profile/presentation/pages/profile_screen.dart';
import 'package:accounting_software/app/features/splash/presentation/cubit/splash_cubit.dart';
import 'package:accounting_software/app/features/splash/presentation/cubit/splash_state.dart';
import 'package:accounting_software/app/features/splash/presentation/pages/splash_screen.dart';
import 'package:accounting_software/app/main_navigation_bar/presentation/pages/main_pages_screen.dart';

class AppRouter {
  static final AuthCubit authCubit = sl<AuthCubit>();
  static final AppSettingsManager settings = sl<AppSettingsManager>();
  static final SplashCubit splashCubit = sl<SplashCubit>();

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash.path,

    routes: _buildRoutes(),
    redirect: _redirect,
    observers: [MyNavObserver()],

    refreshListenable: GoRouterRefreshStream([
      authCubit.stream,
      splashCubit.stream,
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
        path: AppRoutes.splash.path,
        name: AppRoutes.splash.name,
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
        path: AppRoutes.onboarding.path,
        name: AppRoutes.onboarding.name,
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
        path: AppRoutes.login.path,
        name: AppRoutes.login.name,
        pageBuilder: (context, state) =>
            RouteTransitions.fade(context, state, const LoginScreen()),
      ),

      /// ─────────────────────────────────────────
      /// MAIN APP (Bottom Navigation)
      /// ─────────────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainPagesScreen(navigationShell: navigationShell);
        },

        branches: [
          /// ───────── HOME ─────────
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home.path,
                name: AppRoutes.home.name,
                pageBuilder: (context, state) => NoTransitionPage(
                  child: BlocProvider(
                    create: (_) => sl<HomeCubit>()..init(),
                    child: const HomeScreen(),
                  ),
                ),

                routes: [
                  // GoRoute(
                  //   path: 'products',
                  //   name: AppRoutes.products.name,
                  //   builder: (context, state) {
                  //     return const ProductsScreen();
                  //   },
                  // ),

                  // GoRoute(
                  //   path: 'products/:id',
                  //   name: AppRoutes.productDetails.name,
                  //   builder: (context, state) {
                  //     final id = state.pathParameters['id']!;
                  //     return ProductDetailsScreen(id: id);
                  //   },
                  // ),
                ],
              ),
            ],
          ),

          // /// ───────── CHAT ─────────
          // StatefulShellBranch(
          //   routes: [
          //     GoRoute(
          //       path: AppRoutes.chat.path,
          //       name: AppRoutes.chat.name,
          //       pageBuilder: (context, state) =>
          //           const NoTransitionPage(child: ChatScreen()),
          //     ),
          //   ],
          // ),

          /// ───────── FAVORITES ─────────
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.favorites.path,
                name: AppRoutes.favorites.name,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: FavoriteScreen()),
              ),
            ],
          ),

          /// ───────── PROFILE ─────────
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile.path,
                name: AppRoutes.profile.name,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: ProfileScreen()),

                routes: [
                  // GoRoute(
                  //   path: 'orders',
                  //   name: AppRoutes.profileOrders.name,
                  //   builder: (context, state) {
                  //     return const ProfileOrdersScreen();
                  //   },
                  // ),

                  // GoRoute(
                  //   path: 'reviews',
                  //   name: AppRoutes.profileReviews.name,
                  //   builder: (context, state) {
                  //     return const ProfileReviewsScreen();
                  //   },
                  // ),
                ],
              ),
            ],
          ),
        ],
      ),
    ];
  }

  static Future<String?> _redirect(
    BuildContext context,
    GoRouterState state,
  ) async => resolveRedirect(
    location: state.matchedLocation,
    splashDone: splashCubit.state is SplashDone,
    onboarded: await settings.isOnboarded(),
    authState: authCubit.state,
  );
}

class NotFoundScreen extends StatelessWidget {
  final String? location;

  const NotFoundScreen({super.key, this.location});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Page not found")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "404",
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Text(location ?? "Unknown route"),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: () {
                context.go('/home');
              },
              child: const Text("Go Home"),
            ),
          ],
        ),
      ),
    );
  }
}
