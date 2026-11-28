import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:accounting_software/app/core/access/cubit/access_cubit.dart';
import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/core/foundation/config/app_config.dart';
import 'package:accounting_software/app/core/routing/route_transitions.dart';
import 'package:accounting_software/app/features/auth/presentation/cubit/auth_flow/auth_flow_cubit.dart';
import 'package:accounting_software/app/features/auth/presentation/cubit/force_password/force_password_change_cubit.dart';
import 'package:accounting_software/app/features/auth/presentation/cubit/session/session_cubit.dart';
import 'package:accounting_software/app/features/auth/presentation/pages/change_password/force_password_change_screen.dart';
import 'package:accounting_software/app/features/auth/presentation/pages/forgot_password/forgot_password_screen.dart';
import 'package:accounting_software/app/features/auth/presentation/pages/forgot_password/reset_password_screen.dart';
import 'package:accounting_software/app/features/auth/presentation/pages/login/login_screen.dart';
import 'package:accounting_software/app/features/auth/presentation/pages/select_branch/select_branch_screen.dart';
import 'package:accounting_software/app/features/auth/presentation/pages/signup/signup_screen.dart';
import 'package:accounting_software/app/features/auth/presentation/routing/auth_routes.dart';

List<RouteBase> buildAuthGoRoutes({
  required AccessCubit accessCubit,
  bool signupEnabled = AppConfig.signupEnabled,
  bool forgotPasswordEnabled = AppConfig.forgotPasswordEnabled,
}) => [
  GoRoute(
    path: AuthRoutes.login.path,
    name: AuthRoutes.login.name,
    pageBuilder: (context, state) => RouteTransitions.fade(
      context,
      state,
      _withAuthFlow(const LoginScreen()),
    ),
  ),
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
  if (signupEnabled)
    GoRoute(
      path: AuthRoutes.register.path,
      name: AuthRoutes.register.name,
      pageBuilder: (context, state) => RouteTransitions.slide(
        context,
        state,
        _withAuthFlow(const SignUpScreen()),
      ),
    ),
  if (forgotPasswordEnabled)
    GoRoute(
      path: AuthRoutes.forgotPassword.path,
      name: AuthRoutes.forgotPassword.name,
      pageBuilder: (context, state) => RouteTransitions.slide(
        context,
        state,
        _withAuthFlow(const ForgotPasswordScreen()),
      ),
    ),
  if (forgotPasswordEnabled)
    GoRoute(
      path: AuthRoutes.resetPassword.path,
      name: AuthRoutes.resetPassword.name,
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
];

Widget _withAuthFlow(Widget page) => BlocProvider<AuthFlowCubit>(
  create: (_) => sl<AuthFlowCubit>(),
  child: page,
);
