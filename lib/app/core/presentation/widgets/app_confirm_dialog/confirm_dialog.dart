// ─────────────────────────────────────────────────────────────────
// confirm_dialog.dart  (C07)
//
// The one confirmation dialog of the app, in three severities:
//   normal   — a plain yes/no.
//   warning  — says what will change (impactKeys).
//   critical — error colored, names the target; for what cannot be undone it
//              also makes the user type the target's name.
//
// Open it with [showConfirmDialog]; the body is [ConfirmDialogContent].
// ─────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:accounting_software/app/core/localization/keys/common_keys.dart';
import 'package:accounting_software/app/core/localization/keys/dialog_keys.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_inline_banner/inline_banner.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text_field/app_text_field.dart';

enum ConfirmDialogSeverity { normal, warning, critical }

/// The work done when the user confirms.
///
/// Return `null` on success (the dialog closes with `true`). Return an
/// [AppKey] to refuse: the dialog stays open and shows it as an error banner,
/// so a business-rule error never disappears with the dialog.
typedef ConfirmAction = Future<AppKey?> Function();

/// Opens the confirmation and completes with `true` only if the user
/// confirmed (and [onConfirm], if any, succeeded).
///
/// - **Mobile + [ConfirmDialogSeverity.normal]:** a bottom sheet.
/// - **Everything else:** a centered dialog. The critical one is never a
///   sheet, so it cannot be confirmed by a swipe or a stray tap.
///
/// [requireTypedName] is only for what cannot be undone (a permanent lock, a
/// balance posting). It makes the user type [targetName] before the confirm
/// button works. Do not use it elsewhere: it is friction.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required AppKey titleKey,
  required AppKey messageKey,
  Map<String, String>? messageArgs,
  ConfirmDialogSeverity severity = ConfirmDialogSeverity.normal,
  List<AppKey> impactKeys = const [],
  String? targetName,
  bool requireTypedName = false,
  AppKey? confirmLabelKey,
  AppKey? cancelLabelKey,
  ConfirmAction? onConfirm,
}) async {
  final sheet =
      context.ui.screen.isMobile && severity == ConfirmDialogSeverity.normal;

  Widget content({required bool stacked}) => ConfirmDialogContent(
    titleKey: titleKey,
    messageKey: messageKey,
    messageArgs: messageArgs,
    severity: severity,
    impactKeys: impactKeys,
    targetName: targetName,
    requireTypedName: requireTypedName,
    confirmLabelKey: confirmLabelKey,
    cancelLabelKey: cancelLabelKey,
    onConfirm: onConfirm,
    stacked: stacked,
  );

  final bool? result;
  if (sheet) {
    result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) => Padding(
        // Keeps the content above the keyboard.
        padding: MediaQuery.viewInsetsOf(sheetContext),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(sheetContext.ui.spacing.lg),
          child: content(stacked: true),
        ),
      ),
    );
  } else {
    result = await showDialog<bool>(
      context: context,
      // A critical confirmation is not dismissed by tapping outside. (Flutter
      // also turns Esc off when the barrier is not dismissible, so the
      // content handles Esc itself: see CallbackShortcuts below.)
      barrierDismissible: severity != ConfirmDialogSeverity.critical,
      builder: (dialogContext) => Dialog(
        insetPadding: EdgeInsets.all(dialogContext.ui.spacing.lg),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: AppComponentSize.cardWidth.of(dialogContext) * 1.5,
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(dialogContext.ui.spacing.lg),
            child: content(stacked: false),
          ),
        ),
      ),
    );
  }

  return result ?? false;
}

class ConfirmDialogContent extends StatefulWidget {
  const ConfirmDialogContent({
    super.key,
    required this.titleKey,
    required this.messageKey,
    this.messageArgs,
    this.severity = ConfirmDialogSeverity.normal,
    this.impactKeys = const [],
    this.targetName,
    this.requireTypedName = false,
    this.confirmLabelKey,
    this.cancelLabelKey,
    this.onConfirm,
    this.stacked = false,
  }) : assert(
         !requireTypedName ||
             (severity == ConfirmDialogSeverity.critical &&
                 targetName != null &&
                 targetName != ''),
         'requireTypedName needs a critical severity and a targetName',
       );

  final AppKey titleKey;
  final AppKey messageKey;
  final Map<String, String>? messageArgs;
  final ConfirmDialogSeverity severity;

  /// What will change, one line each (warning and critical).
  final List<AppKey> impactKeys;

  /// The thing being acted on. It is user data, so it is shown as it is.
  final String? targetName;

  final bool requireTypedName;
  final AppKey? confirmLabelKey;
  final AppKey? cancelLabelKey;
  final ConfirmAction? onConfirm;

  /// Buttons full width, one above the other (the bottom sheet).
  final bool stacked;

  @override
  State<ConfirmDialogContent> createState() => _ConfirmDialogContentState();
}

class _ConfirmDialogContentState extends State<ConfirmDialogContent> {
  final _typed = TextEditingController();
  bool _busy = false;
  AppKey? _error;

  bool get _critical => widget.severity == ConfirmDialogSeverity.critical;

  /// The typed name matches (or none is required). Whitespace around it is
  /// ignored; the letters must match exactly.
  bool get _nameOk =>
      !widget.requireTypedName ||
      _typed.text.trim() == widget.targetName!.trim();

  @override
  void initState() {
    super.initState();
    _typed.addListener(_onTyped);
  }

  @override
  void dispose() {
    _typed
      ..removeListener(_onTyped)
      ..dispose();
    super.dispose();
  }

  void _onTyped() => setState(() {});

  void _cancel() {
    if (_busy) return;
    Navigator.of(context).pop(false);
  }

  Future<void> _confirm() async {
    // `_busy` is set before the first await, so a double click cannot start
    // the action twice.
    if (_busy || !_nameOk) return;

    final action = widget.onConfirm;
    if (action == null) {
      Navigator.of(context).pop(true);
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });

    AppKey? refusal;
    try {
      refusal = await action();
    } catch (_) {
      refusal = CommonKeys.unknownError;
    }
    if (!mounted) return;

    if (refusal == null) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _busy = false;
        _error = refusal;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      // Esc cancels (and does nothing while the action runs).
      bindings: {const SingleActivator(LogicalKeyboardKey.escape): _cancel},
      child: PopScope(
        // No back gesture while the action runs.
        canPop: !_busy,
        child: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final ui = context.ui;
    final scheme = ui.theme.colors;
    final severity = widget.severity;
    final targetName = widget.targetName;

    final message = widget.messageKey.tr(
      context: context,
      namedArgs: widget.messageArgs,
    );

    final confirmButton = AppButton(
      widget.confirmLabelKey ?? CommonKeys.confirm,
      variant: _critical ? AppButtonVariant.danger : AppButtonVariant.primary,
      isLoading: _busy,
      // While busy the button is not tappable but keeps its normal look
      // (AppButton.isLoading), so the spinner is the only change.
      onPressed: _nameOk ? _confirm : null,
      expand: widget.stacked,
    );

    final cancelButton = AppButton(
      widget.cancelLabelKey ?? CommonKeys.cancel,
      variant: AppButtonVariant.outlined,
      onPressed: _busy ? null : _cancel,
      // A critical action opens with focus on Cancel: Enter cannot confirm.
      autofocus: _critical,
      expand: widget.stacked,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (severity != ConfirmDialogSeverity.normal) ...[
              AppIcon(
                _critical ? AppIcons.error : AppIcons.warning,
                color: _critical
                    ? scheme.error
                    : ui.theme.semanticColors.warning,
                semanticsLabel:
                    (_critical
                            ? DialogKeys.criticalLabel
                            : DialogKeys.warningLabel)
                        .tr(context: context),
              ),
              ui.spacing.gap(AppSpacing.sm, axis: Axis.horizontal),
            ],
            Expanded(
              child: AppText(
                widget.titleKey,
                type: AppTextType.titleLarge,
                color: _critical ? scheme.error : null,
              ),
            ),
          ],
        ),
        ui.spacing.gap(AppSpacing.md, axis: Axis.vertical),
        AppText.raw(message, type: AppTextType.bodyMedium),
        if (widget.impactKeys.isNotEmpty) ...[
          ui.spacing.gap(AppSpacing.md, axis: Axis.vertical),
          const AppText(DialogKeys.impactTitle, type: AppTextType.labelLarge),
          ui.spacing.gap(AppSpacing.xs, axis: Axis.vertical),
          for (final impact in widget.impactKeys)
            Padding(
              padding: EdgeInsetsDirectional.only(top: ui.spacing.xs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppText.raw('•', type: AppTextType.bodyMedium),
                  ui.spacing.gap(AppSpacing.sm, axis: Axis.horizontal),
                  Expanded(
                    child: AppText(impact, type: AppTextType.bodyMedium),
                  ),
                ],
              ),
            ),
        ],
        if (targetName != null && targetName.isNotEmpty) ...[
          ui.spacing.gap(AppSpacing.md, axis: Axis.vertical),
          AppText.raw(
            targetName,
            type: AppTextType.bodyMedium,
            weight: FontWeight.w700,
          ),
        ],
        if (widget.requireTypedName) ...[
          ui.spacing.gap(AppSpacing.md, axis: Axis.vertical),
          AppText.raw(
            DialogKeys.typeToConfirm.tr(
              context: context,
              namedArgs: {'name': targetName!},
            ),
            type: AppTextType.bodySmall,
          ),
          ui.spacing.gap(AppSpacing.sm, axis: Axis.vertical),
          AppTextField(
            controller: _typed,
            labelKey: DialogKeys.typedNameLabel,
            enabled: !_busy,
            // Enter in this field must not confirm.
            textInputAction: TextInputAction.done,
          ),
        ],
        if (_error != null) ...[
          ui.spacing.gap(AppSpacing.md, axis: Axis.vertical),
          InlineBanner(messageKey: _error!, variant: InlineBannerVariant.error),
        ],
        ui.spacing.gap(AppSpacing.lg, axis: Axis.vertical),
        if (widget.stacked)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              confirmButton,
              ui.spacing.gap(AppSpacing.sm, axis: Axis.vertical),
              cancelButton,
            ],
          )
        else
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Wrap(
              spacing: ui.spacing.sm,
              runSpacing: ui.spacing.sm,
              children: [cancelButton, confirmButton],
            ),
          ),
      ],
    );
  }
}
