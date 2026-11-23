import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:accounting_software/app/core/localization/keys/common_keys.dart';
import 'package:accounting_software/app/core/localization/keys/template_keys.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_confirm_dialog/confirm_dialog.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_inline_banner/inline_banner.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';

/// Shared responsive shell for create/edit forms.
///
/// A successful save is closed explicitly by the caller with
/// `Navigator.pop(context, true)`; that programmatic close intentionally
/// bypasses this widget's dirty-form guard.
class AppFormDialog extends StatefulWidget {
  const AppFormDialog({
    super.key,
    required this.titleKey,
    required this.child,
    required this.onSave,
    this.subtitleKey,
    this.saveLabelKey,
    this.cancelLabelKey,
    this.saveEnabled = true,
    this.busy = false,
    this.dirty = false,
    this.errorKey,
  });

  final AppKey titleKey;
  final AppKey? subtitleKey;
  final Widget child;
  final AppKey? saveLabelKey;
  final AppKey? cancelLabelKey;
  final Future<void> Function() onSave;
  final bool saveEnabled;
  final bool busy;
  final bool dirty;
  final AppKey? errorKey;

  @override
  State<AppFormDialog> createState() => _AppFormDialogState();
}

class _AppFormDialogState extends State<AppFormDialog> {
  Future<void> _requestClose() async {
    if (widget.busy) return;
    if (!widget.dirty) {
      Navigator.of(context).pop(false);
      return;
    }

    final confirmed = await showConfirmDialog(
      context,
      titleKey: widget.titleKey,
      messageKey: TemplateKeys.unsavedChanges,
      severity: ConfirmDialogSeverity.warning,
    );
    if (confirmed && mounted && !widget.busy) {
      Navigator.of(context).pop(false);
    }
  }

  Future<void> _save() async {
    if (widget.busy || !widget.saveEnabled) return;
    await widget.onSave();
  }

  @override
  Widget build(BuildContext context) => CallbackShortcuts(
    bindings: {const SingleActivator(LogicalKeyboardKey.escape): _requestClose},
    child: Focus(
      autofocus: true,
      child: PopScope(
        canPop: !widget.busy && !widget.dirty,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) _requestClose();
        },
        child: _buildSurface(context),
      ),
    ),
  );

  Widget _buildSurface(BuildContext context) {
    final ui = context.ui;
    final isDialog = !ui.screen.isMobile;
    final content = <Widget>[
      if (widget.errorKey != null) ...[
        InlineBanner(
          messageKey: widget.errorKey!,
          variant: InlineBannerVariant.error,
        ),
        ui.spacing.gap(AppSpacing.md),
      ],
      widget.child,
    ];
    final header = Padding(
      padding: ui.padding.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppText(widget.titleKey, type: AppTextType.titleLarge),
          if (widget.subtitleKey != null) ...[
            ui.spacing.gap(AppSpacing.xs),
            AppText(widget.subtitleKey!, type: AppTextType.bodySmall),
          ],
        ],
      ),
    );
    final footer = Padding(
      padding: ui.padding.all(AppSpacing.lg),
      child: Wrap(
        alignment: WrapAlignment.end,
        spacing: ui.spacing.sm,
        runSpacing: ui.spacing.sm,
        children: [
          AppButton(
            widget.cancelLabelKey ?? CommonKeys.cancel,
            variant: AppButtonVariant.text,
            onPressed: widget.busy ? null : _requestClose,
          ),
          AppButton(
            widget.saveLabelKey ?? CommonKeys.save,
            isLoading: widget.busy,
            onPressed: widget.busy || !widget.saveEnabled ? null : _save,
          ),
        ],
      ),
    );

    if (isDialog) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          header,
          Flexible(
            child: SingleChildScrollView(
              padding: ui.padding.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: content,
              ),
            ),
          ),
          footer,
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        header,
        Expanded(
          child: SingleChildScrollView(
            padding: ui.padding.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: content,
            ),
          ),
        ),
        footer,
      ],
    );
  }
}

/// Opens the shared form shell as a centered dialog or a full-height mobile
/// sheet. The PopScope intercepts back and barrier taps for dirty or busy forms.
///
/// Dragging the sheet down is disabled: a drag ends in `Navigator.pop`, which
/// bypasses PopScope and would discard unsaved input. The sheet is full height
/// and its content scrolls, so a drag gesture would fight the form anyway.
Future<T?> showAppFormDialog<T>(BuildContext context, WidgetBuilder builder) {
  if (context.ui.screen.isMobile) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      isDismissible: true,
      enableDrag: false,
      builder: (sheetContext) => AnimatedPadding(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
        ),
        child: SizedBox.expand(child: builder(sheetContext)),
      ),
    );
  }

  return showDialog<T>(
    context: context,
    barrierDismissible: true,
    useSafeArea: true,
    builder: (dialogContext) => Dialog(
      insetPadding: EdgeInsets.all(dialogContext.ui.spacing.lg),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: AppComponentSize.formDialogWidth.of(dialogContext),
          maxHeight:
              MediaQuery.sizeOf(dialogContext).height -
              dialogContext.ui.spacing.lg * 2,
        ),
        child: builder(dialogContext),
      ),
    ),
  );
}
