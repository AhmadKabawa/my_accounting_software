import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/localization/keys/template_keys.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_confirm_dialog/confirm_dialog.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_empty_state/app_empty_state.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_inline_banner/inline_banner.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_page_header/app_page_header.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_skeleton/app_skeleton.dart';

enum AppPageState { content, loading, empty, error }

/// T3 form frame. The screen owns fields, validation and business state.
///
/// [child] may be an ordinary form widget, which this template makes
/// scrollable, or a [ScrollView] such as [ListView], which is used directly
/// to avoid nesting scroll views.
class FormPageTemplate extends StatefulWidget {
  const FormPageTemplate({
    super.key,
    required this.titleKey,
    required this.child,
    this.state = AppPageState.content,
    this.errorKey,
    this.emptyState,
    this.dirty = false,
    this.onDiscard,
    this.onSave,
    this.saving = false,
  });

  final AppKey titleKey;
  final Widget child;
  final AppPageState state;
  final AppKey? errorKey;
  final Widget? emptyState;
  final bool dirty;
  final VoidCallback? onDiscard;
  final VoidCallback? onSave;
  final bool saving;

  @override
  State<FormPageTemplate> createState() => _FormPageTemplateState();
}

class _FormPageTemplateState extends State<FormPageTemplate> {
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
      canPop: !widget.dirty,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop || !widget.dirty) return;
        final leave = await _confirmLeave();
        if (leave && mounted) {
          // Navigator.pop bypasses this PopScope's canPop check. Calling
          // maybePop here would re-check the stale canPop value and reopen
          // the confirmation dialog before the next frame rebuilds.
          Navigator.of(context).pop();
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppPageHeader(titleKey: widget.titleKey),
          if (widget.state == AppPageState.error)
            InlineBanner(
              messageKey: widget.errorKey ?? TemplateKeys.defaultError,
              variant: InlineBannerVariant.error,
            ),
          Expanded(child: _scrollableBody()),
          if (widget.onSave != null)
            AppButton(
              TemplateKeys.save,
              onPressed: widget.saving ? null : widget.onSave,
              isLoading: widget.saving,
              expand: true,
            ),
        ],
      ),
    );
  }

  Widget _emptyState() => AppEmptyState(
    icon: AppIcons.info,
    titleKey: TemplateKeys.emptyTitle,
    descriptionKey: TemplateKeys.emptyDescription,
  );

  Widget _stateBody() => switch (widget.state) {
    AppPageState.loading => const Column(
      children: [AppSkeleton.line(), AppSkeleton.block()],
    ),
    AppPageState.empty => widget.emptyState ?? _emptyState(),
    AppPageState.error || AppPageState.content => widget.child,
  };

  Widget _scrollableBody() {
    final body = _stateBody();
    if (body is ScrollView) return body;
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: body,
        ),
      ),
    );
  }
}

/// T5 dashboard frame. The screen supplies role-filtered cards.
class DashboardTemplate extends StatelessWidget {
  const DashboardTemplate({
    super.key,
    required this.titleKey,
    required this.cards,
    this.state = AppPageState.content,
    this.errorKey,
    this.emptyState,
  });

  final AppKey titleKey;
  final List<Widget> cards;
  final AppPageState state;
  final AppKey? errorKey;
  final Widget? emptyState;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppPageHeader(titleKey: titleKey),
        if (state == AppPageState.error)
          InlineBanner(
            messageKey: errorKey ?? TemplateKeys.defaultError,
            variant: InlineBannerVariant.error,
          ),
        Expanded(
          child: switch (state) {
            AppPageState.loading => const AppSkeleton.card(),
            AppPageState.empty => _emptyState(),
            AppPageState.content || AppPageState.error =>
              cards.isEmpty ? _emptyState() : _cardsGrid(context),
          },
        ),
      ],
    );
  }

  Widget _emptyState() =>
      emptyState ??
      AppEmptyState(
        icon: AppIcons.info,
        titleKey: TemplateKeys.emptyTitle,
        descriptionKey: TemplateKeys.emptyDescription,
      );

  Widget _cardsGrid(BuildContext context) => GridView.builder(
    padding: context.ui.padding.all(AppSpacing.md),
    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
      maxCrossAxisExtent: context.ui.size.width(AppComponentSize.cardWidth),
      crossAxisSpacing: context.ui.spacing.md,
      mainAxisSpacing: context.ui.spacing.md,
    ),
    itemCount: cards.length,
    itemBuilder: (_, index) => cards[index],
  );
}
