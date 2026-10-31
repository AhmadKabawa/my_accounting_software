import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:accounting_software/app/core/di/features_di/on_boarding_di.dart';
import 'package:accounting_software/app/core/foundation/localization/cubit/locale_cubit.dart';
import 'package:accounting_software/app/core/foundation/localization/cubit/locale_state.dart';
import 'package:accounting_software/app/core/presentation/theme/app_theme.dart';
import 'package:accounting_software/app/core/presentation/theme/logic/cubit/theme_cubit.dart';
import 'package:accounting_software/app/core/routing/app_go_router.dart';
import 'package:accounting_software/app/core/services/local_storage/secure_storage/token_manager.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => sl<ThemeCubit>()..loadSavedTheme()),
        BlocProvider(
          create: (context) => sl<LocaleCubit>()..loadSavedLanguage(),
        ),
      ],
      child: BlocListener<LocaleCubit, LocaleState>(
        listenWhen: (prev, curr) => prev != curr,
        listener: (context, locale) {
          context.setLocale(locale.locale);
        },
        child: BlocBuilder<ThemeCubit, ThemeState>(
          builder: (context, themeState) {
            return MaterialApp.router(
              debugShowCheckedModeBanner: false,
              locale: context.locale,
              supportedLocales: context.supportedLocales,
              localizationsDelegates: context.localizationDelegates,
              routerConfig: AppRouter.router,
              theme: AppTheme.light(context),
              darkTheme: AppTheme.dark(context),
              themeMode: themeState.themeMode,

              builder: (context, child) {
                final mq = MediaQuery.of(context);
                return MediaQuery(
                  // The only place the system text scale is capped.
                  data: mq.copyWith(
                    textScaler: mq.textScaler.clamp(
                      minScaleFactor: 0.9,
                      maxScaleFactor: 1.3,
                    ),
                  ),
                  child: Scaffold(
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.startFloat,
                // Debug-only controls: they clear the session and must never
                // reach release builds.
                floatingActionButton: !kDebugMode
                    ? null
                    : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FloatingActionButton.small(
                      backgroundColor: Colors.red,
                      onPressed: () {
                        sl<TokenManager>().clearTokens();
                      },
                      child: const Text("storage"),
                    ),
                    FloatingActionButton.small(
                      onPressed: () {
                        context.read<LocaleCubit>().toggleLanguage();
                      },
                      child: const Text("Language"),
                    ),
                    FloatingActionButton.small(
                      onPressed: () {
                        context.read<ThemeCubit>().toggleTheme();
                      },
                      child: const Text("theme"),
                    ),
                  ],
                ),
                body: child,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
