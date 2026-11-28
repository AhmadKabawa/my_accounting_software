import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:accounting_software/app/core/localization/keys/common_keys.dart';
import 'package:accounting_software/app/core/localization/keys/error_keys.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/features/home/presentation/routing/home_routes.dart';

/// Informational destination used when a signed-in user opens a route
/// without the required application permission.
class AccessDeniedScreen extends StatelessWidget {
  const AccessDeniedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gap = context.ui.spacing.gap(AppSpacing.lg, axis: Axis.vertical);
    return Scaffold(
      body: Center(
        child: Padding(
          padding: context.ui.padding.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AppText(ErrorKeys.forbidden, type: AppTextType.titleLarge),
              gap,
              AppButton(
                CommonKeys.goHome,
                onPressed: () => context.go(HomeRoutes.home.path),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
