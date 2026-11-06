import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:accounting_software/app/core/localization/keys/common_keys.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/core/routing/routes.dart';

/// The router's `errorPageBuilder` page for unknown locations.
class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key, this.location});

  final String? location;

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
              const AppText.raw('404', type: AppTextType.displayMedium),
              gap,
              AppText(CommonKeys.pageNotFound, type: AppTextType.titleLarge),
              if (location != null) AppText.raw(location, textAlign: TextAlign.center),
              gap,
              AppButton(
                CommonKeys.goHome,
                onPressed: () => context.go(AppRoutes.home.path),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
