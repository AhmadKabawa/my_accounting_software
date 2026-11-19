// ─────────────────────────────────────────────────────────────────
// scope_selector.dart  (C12)
//
// Picks the branch / warehouse / currency the screen works in (top bar and
// filters). One widget for all three: the caller says what it is picking with
// [ScopeSelector.labelKey].
// ─────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/localization/keys/scope_keys.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_badge/app_badge.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';

/// One thing the user can pick. [name] is data (a branch name), so it is shown
/// as it is, not translated.
class ScopeOption {
  const ScopeOption({
    required this.id,
    required this.name,
    this.viewOnly = false,
  });

  final String id;
  final String name;

  /// The user may look at this scope but not change anything in it. Shown as
  /// a "view only" badge next to the name. This is a *display* of the access
  /// the server already decided; the server stays the authority.
  final bool viewOnly;
}

/// Branch / warehouse / currency picker.
///
/// - **One option:** the name is shown as plain text, with no menu and no
///   arrow, because there is nothing to choose.
/// - **Several options:** mobile opens a bottom sheet; web and Windows open a
///   menu under the control.
/// - **View only:** a text badge next to the name (never color alone).
/// - **Switching with unsaved work:** pass [beforeChange]; the switch only
///   happens if it returns `true` (the screen opens a `ConfirmDialog` there,
///   e.g. when a cart is open). The selector holds no cart logic itself.
class ScopeSelector extends StatelessWidget {
  const ScopeSelector({
    super.key,
    required this.labelKey,
    required this.options,
    required this.selectedId,
    required this.onChanged,
    this.beforeChange,
  });

  /// What is being picked ("Branch"). Also the accessible name.
  final AppKey labelKey;

  final List<ScopeOption> options;
  final String? selectedId;
  final ValueChanged<ScopeOption> onChanged;

  /// Asked before a switch. Return `false` to keep the current scope.
  final Future<bool> Function(ScopeOption next)? beforeChange;

  ScopeOption? get _selected {
    for (final option in options) {
      if (option.id == selectedId) return option;
    }
    return null;
  }

  Future<void> _choose(ScopeOption next) async {
    if (next.id == selectedId) return;
    final allowed = await beforeChange?.call(next) ?? true;
    if (allowed) onChanged(next);
  }

  Future<void> _openSheet(BuildContext context) async {
    final next = await showModalBottomSheet<ScopeOption>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(sheetContext.ui.spacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsetsDirectional.only(
                  start: sheetContext.ui.spacing.sm,
                  bottom: sheetContext.ui.spacing.sm,
                ),
                child: AppText(labelKey, type: AppTextType.titleMedium),
              ),
              for (final option in options)
                _OptionRow(
                  option: option,
                  selected: option.id == selectedId,
                  onTap: () => Navigator.of(sheetContext).pop(option),
                ),
            ],
          ),
        ),
      ),
    );
    if (next != null) await _choose(next);
  }

  @override
  Widget build(BuildContext context) {
    if (options.isEmpty) return const SizedBox.shrink();

    final selected = _selected;

    // Nothing to choose: show the name, not a control.
    if (options.length == 1) {
      return _Trigger(
        labelKey: labelKey,
        option: options.single,
        selectable: false,
      );
    }

    final trigger = _Trigger(
      labelKey: labelKey,
      option: selected,
      selectable: true,
    );

    if (context.ui.screen.isMobile) {
      return InkWell(
        borderRadius: AppRadius.sm.circular(context),
        onTap: () => _openSheet(context),
        child: trigger,
      );
    }

    return PopupMenuButton<ScopeOption>(
      tooltip: labelKey.tr(context: context),
      position: PopupMenuPosition.under,
      onSelected: _choose,
      itemBuilder: (_) => [
        for (final option in options)
          PopupMenuItem<ScopeOption>(
            value: option,
            child: _OptionContent(
              option: option,
              selected: option.id == selectedId,
            ),
          ),
      ],
      child: trigger,
    );
  }
}

/// The closed control: name, view-only badge, and an arrow when selectable.
class _Trigger extends StatelessWidget {
  const _Trigger({
    required this.labelKey,
    required this.option,
    required this.selectable,
  });

  final AppKey labelKey;
  final ScopeOption? option;
  final bool selectable;

  @override
  Widget build(BuildContext context) {
    final ui = context.ui;
    final name = option?.name;

    return Semantics(
      button: selectable,
      label: labelKey.tr(context: context),
      value: name,
      child: ExcludeSemantics(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: AppComponentSize.hitArea.of(context),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: ui.spacing.sm),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: name == null
                      ? AppText(labelKey, type: AppTextType.bodyMedium)
                      : AppText.raw(
                          name,
                          type: AppTextType.bodyMedium,
                          weight: FontWeight.w600,
                          maxLines: 1,
                          useEllipsis: true,
                        ),
                ),
                if (option?.viewOnly ?? false) ...[
                  ui.spacing.gap(AppSpacing.sm, axis: Axis.horizontal),
                  const AppBadge(
                    label: ScopeKeys.viewOnly,
                    tone: AppBadgeTone.neutral,
                    size: AppBadgeSize.small,
                  ),
                ],
                if (selectable) ...[
                  ui.spacing.gap(AppSpacing.xs, axis: Axis.horizontal),
                  const AppIcon(AppIcons.expand, size: AppIconSize.md),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A row of the bottom sheet.
class _OptionRow extends StatelessWidget {
  const _OptionRow({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final ScopeOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: AppRadius.sm.circular(context),
      onTap: onTap,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: AppComponentSize.hitArea.of(context),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: context.ui.spacing.sm),
          child: _OptionContent(option: option, selected: selected),
        ),
      ),
    );
  }
}

/// Name, badge and a check mark when it is the current one. Shared by the
/// sheet and the menu.
class _OptionContent extends StatelessWidget {
  const _OptionContent({required this.option, required this.selected});

  final ScopeOption option;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final ui = context.ui;

    return Semantics(
      selected: selected,
      child: Row(
        children: [
          Expanded(
            child: AppText.raw(
              option.name,
              type: AppTextType.bodyMedium,
              weight: selected ? FontWeight.w700 : null,
              maxLines: 1,
              useEllipsis: true,
            ),
          ),
          if (option.viewOnly) ...[
            ui.spacing.gap(AppSpacing.sm, axis: Axis.horizontal),
            const AppBadge(
              label: ScopeKeys.viewOnly,
              tone: AppBadgeTone.neutral,
              size: AppBadgeSize.small,
            ),
          ],
          if (selected) ...[
            ui.spacing.gap(AppSpacing.sm, axis: Axis.horizontal),
            // The check is the second signal (the first is the bold name),
            // and its label tells a screen reader which one is current.
            AppIcon(
              AppIcons.check,
              size: AppIconSize.md,
              semanticsLabel: ScopeKeys.current.tr(context: context),
            ),
          ],
        ],
      ),
    );
  }
}
