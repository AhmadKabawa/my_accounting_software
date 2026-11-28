import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/core/foundation/config/app_config.dart';
import 'package:accounting_software/app/core/routing/route_transitions.dart';
import 'package:accounting_software/app/features/on_boarding/presentation/cubit/on_boarding_cubit.dart';
import 'package:accounting_software/app/features/on_boarding/presentation/pages/on_boarding_screen.dart';
import 'package:accounting_software/app/features/on_boarding/presentation/routing/on_boarding_routes.dart';

List<RouteBase> buildOnBoardingGoRoutes({
  bool enabled = AppConfig.onboardingEnabled,
}) => [
  if (enabled)
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
];
