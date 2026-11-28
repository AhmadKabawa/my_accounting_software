import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:accounting_software/app/core/routing/route_transitions.dart';
import 'package:accounting_software/app/features/splash/presentation/cubit/splash_cubit.dart';
import 'package:accounting_software/app/features/splash/presentation/pages/splash_screen.dart';
import 'package:accounting_software/app/features/splash/presentation/routing/splash_routes.dart';

List<RouteBase> buildSplashGoRoutes({required SplashCubit splashCubit}) => [
  GoRoute(
    path: SplashRoutes.splash.path,
    name: SplashRoutes.splash.name,
    pageBuilder: (context, state) => RouteTransitions.fade(
      context,
      state,
      BlocProvider.value(value: splashCubit, child: const SplashScreen()),
    ),
  ),
];
