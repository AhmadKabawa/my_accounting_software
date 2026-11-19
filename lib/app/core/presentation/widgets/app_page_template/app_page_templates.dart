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

/// T3 form frame. The screen owns fields, validation and business state.
class FormPageTemplate extends StatefulWidget {
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

  @override
  State<FormPageTemplate> createState() => _FormPageTemplateState();
}

class _FormPageTemplateState extends State<FormPageTemplate> {
  bool _allowPop = false;

  Future<bool> _confirmLeave() async {
    if (!widget.dirty) return true;
    final confirmed = await showConfirmDialog(
      context,
      titleKey: widget.titleKey,
      messageKey: TemplateKeys.unsavedChanges,
      severity: ConfirmDialogSeverity.warning,
    );
    if (confirmed) widget.onDiscard?.call();
    return confirmed;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !widget.dirty || _allowPop,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop || !widget.dirty) return;
        final leave = await _confirmLeave();
        if (leave && mounted) {
          setState(() => _allowPop = true);
          Navigator.of(context).maybePop();
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppPageHeader(
            titleKey: widget.titleKey,
            primaryAction: widget.primaryAction,
          ),
          if (widget.state == AppPageState.error && widget.errorKey != null)
            InlineBanner(
              messageKey: widget.errorKey!,
              variant: InlineBannerVariant.error,
            ),
          Expanded(child: _stateBody()),
          if (widget.onSave != null)
            AppButton(
              TemplateKeys.save,
              onPressed: widget.onSave,
              expand: true,
            ),
        ],
      ),
    );
  }

  Widget _stateBody() => switch (widget.state) {
    AppPageState.loading => const Column(
      children: [AppSkeleton.line(), AppSkeleton.block()],
    ),
    AppPageState.empty => widget.emptyState ?? const SizedBox.shrink(),
    AppPageState.error || AppPageState.content => widget.child,
  };
}

/// T5 dashboard frame. The screen supplies role-filtered cards.
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
          InlineBanner(
            messageKey: errorKey!,
            variant: InlineBannerVariant.error,
          ),
        Expanded(
          child: loading
              ? const AppSkeleton.card()
              : GridView.builder(
                  padding: context.ui.padding.all(AppSpacing.md),
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: context.ui.size.width(
                      AppComponentSize.cardWidth,
                    ),
                    crossAxisSpacing: context.ui.spacing.md,
                    mainAxisSpacing: context.ui.spacing.md,
                  ),
                  itemCount: cards.length,
                  itemBuilder: (_, index) => cards[index],
                ),
        ),
      ],
    );
  }
}
