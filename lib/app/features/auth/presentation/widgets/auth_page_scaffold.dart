import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_appbar/app_page_app_bar.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/flash_messages.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';

/// The frame shared by every auth page: safe area, scrolling, a width limit on
/// tablets/desktops, the title block, and the [FlashMessageListener] that shows
/// messages (errors of this page, "signed out", "session expired"...). A new
/// auth page only supplies its [child].
class AuthPageScaffold extends StatelessWidget {
  const AuthPageScaffold({
    super.key,
    required this.titleKey,
    required this.child,
    this.subtitleKey,
    this.showBack = false,
  });

  final AppKey titleKey;
  final AppKey? subtitleKey;
  final Widget child;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    final maxWidth = context.ui.grid.value<double>(
      mobile: double.infinity,
      tablet: context.ui.size.width(AppComponentSize.cardWidth) * 1.25,
    );

    return FlashMessageListener(
      child: Scaffold(
        appBar: showBack ? const AppPageAppBar() : null,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: context.ui.padding.all(AppSpacing.lg),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppText(titleKey, type: AppTextType.headlineMedium),
                    if (subtitleKey != null) ...[
                      context.ui.spacing.gap(AppSpacing.xs, axis: Axis.vertical),
                      AppText(subtitleKey!, type: AppTextType.bodyMedium),
                    ],
                    context.ui.spacing.gap(AppSpacing.xl, axis: Axis.vertical),
                    child,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
