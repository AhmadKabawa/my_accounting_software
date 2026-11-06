import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/state_management/bloc_effect_listener.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/message_view_widgets.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:accounting_software/app/features/auth/presentation/cubit/effect/auth_effect.dart';

/// The frame shared by every auth page: safe area, scrolling, a width limit on
/// tablets/desktops, the title block and the single place that turns
/// [AuthEffect]s into messages. A new auth page only supplies its [child].
///
/// Requires an [AuthCubit] above it (the router provides the shared singleton
/// with `BlocProvider.value`).
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

    return Scaffold(
      appBar: showBack ? AppBar() : null,
      body: SafeArea(
        child: BlocEffectListener<AuthEffect, AuthCubit>(
          onEffect: (context, effect) => effect.whenOrNull(
            showMessage: (key, type) => MessageViewWidgets.showMessage(
              context,
              messageKey: key,
              type: type,
            ),
          ),
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
