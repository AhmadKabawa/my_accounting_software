import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/localization/keys/template_keys.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_confirm_dialog/confirm_dialog.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_inline_banner/inline_banner.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_page_header/app_page_header.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_skeleton/app_skeleton.dart';

enum AppPageState { content, loading, empty, error }

/// T3 form page frame. The owning screen supplies fields and business state.
class FormPageTemplate extends StatelessWidget {
  const FormPageTemplate({
    super.key,
    required this.titleKey,
    required this.child,
    this.state = AppPageState.content,
    this.errorKey,
    this.emptyState,
    this.primaryAction,
    this.dirty = false,
    this.onDiscard,
    this.onSave,
  });

  final AppKey titleKey;
  final Widget child;
  final AppPageState state;
  final AppKey? errorKey;
  final Widget? emptyState;
  final Widget? primaryAction;
  final bool dirty;
  final VoidCallback? onDiscard;
  final VoidCallback? onSave;

  Future<bool> _confirmLeave(BuildContext context) async {
    if (!dirty) return true;
    final confirmed = await showConfirmDialog(
      context,
      titleKey: titleKey,
      messageKey: TemplateKeys.unsavedChanges,
      severity: ConfirmDialogSeverity.warning,
    );
    if (confirmed) onDiscard?.call();
    return confirmed;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !dirty,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop || !dirty) return;
        final leave = await _confirmLeave(context);
        if (leave && context.mounted) Navigator.of(context).maybePop();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppPageHeader(titleKey: titleKey, primaryAction: primaryAction),
          if (state == AppPageState.error && errorKey != null)
            InlineBanner(messageKey: errorKey!, variant: InlineBannerVariant.error),
          Expanded(child: _stateBody()),
          if (onSave != null)
            AppButton(TemplateKeys.save, onPressed: onSave, expand: true),
        ],
      ),
    );
  }

  Widget _stateBody() => switch (state) {
    AppPageState.loading => const Column(children: [AppSkeleton.line(), AppSkeleton.block()]),
    AppPageState.empty => emptyState ?? const SizedBox.shrink(),
    AppPageState.error || AppPageState.content => child,
  };
}

/// T5 dashboard frame. The screen supplies cards after applying role rules.
class DashboardTemplate extends StatelessWidget {
  const DashboardTemplate({
    super.key,
    required this.titleKey,
    required this.cards,
    this.loading = false,
    this.errorKey,
  });

  final AppKey titleKey;
  final List<Widget> cards;
  final bool loading;
  final AppKey? errorKey;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppPageHeader(titleKey: titleKey),
        if (errorKey != null)
          InlineBanner(messageKey: errorKey!, variant: InlineBannerVariant.error),
        Expanded(
          child: loading
              ? const AppSkeleton.card()
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final cardWidth = context.ui.size.width(AppComponentSize.cardWidth);
                    final columns = constraints.maxWidth >= cardWidth * 2 ? 3 : 2;
                    return GridView.count(
                      padding: context.ui.padding.all(AppSpacing.md),
                      crossAxisCount: columns,
                      crossAxisSpacing: context.ui.spacing.md,
                      mainAxisSpacing: context.ui.spacing.md,
                      children: cards,
                    );
                  },
                ),
        ),
      ],
    );
  }
}
