import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/core/localization/translations/app_keys.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/features/splash/presentation/cubit/splash_cubit.dart';

/// Shown while the session is restored. The router leaves it once
/// `SplashCubit` reports done.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SplashCubit>().init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppText(AppKeys.common.appName, type: AppTextType.headlineMedium),
            context.ui.spacing.gap(AppSpacing.lg, axis: Axis.vertical),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
