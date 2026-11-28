import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/features/auth/presentation/cubit/profile/profile_cubit.dart';
import 'package:accounting_software/app/features/auth/presentation/cubit/session/session_cubit.dart';
import 'package:accounting_software/app/features/profile/presentation/pages/profile_screen.dart';
import 'package:accounting_software/app/features/profile/presentation/routing/profile_routes.dart';

List<RouteBase> buildProfileGoRoutes() => [
  GoRoute(
    path: ProfileRoutes.profile.path,
    name: ProfileRoutes.profile.name,
    pageBuilder: (context, state) => NoTransitionPage(
      child: MultiBlocProvider(
        providers: [
          BlocProvider<SessionCubit>.value(value: sl<SessionCubit>()),
          BlocProvider<ProfileCubit>(create: (_) => sl<ProfileCubit>()),
        ],
        child: const ProfileScreen(),
      ),
    ),
  ),
];
