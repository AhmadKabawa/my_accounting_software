import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/localization/keys/catalog_ui_keys.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';

/// A field the list can be sorted by (the database does the sorting).
class FilterBarSortOption {
  const FilterBarSortOption({required this.key, required this.label});
  final String key;
  final AppKey label;
}

/// One active sort criterion: a field key and its direction.
class FilterBarSort {
  const FilterBarSort(this.key, this.ascending);
  final String key;
  final bool ascending;

  @override
  bool operator ==(Object other) =>
      other is FilterBarSort &&
      other.key == key &&
      other.ascending == ascending;

  @override
  int get hashCode => Object.hash(key, ascending);
}

/// The next list of criteria after the user pressed the up ([ascending]) or
/// down arrow of [key]:
/// * pressing the arrow that is already on removes that criterion (the last
///   one cannot be removed: a list is always sorted by something);
/// * pressing the other arrow flips the direction;
/// * a new field is added as the lowest priority, and the oldest criterion
///   is dropped when there would be more than [maxSorts].
List<FilterBarSort> toggleSort(
  List<FilterBarSort> current,
  String key,
  bool ascending, {
  int maxSorts = 2,
}) {
  final next = [...current];
  final index = next.indexWhere((s) => s.key == key);
  if (index >= 0) {
    if (next[index].ascending == ascending) {
      if (next.length > 1) next.removeAt(index);
    } else {
      next[index] = FilterBarSort(key, ascending);
    }
    return next;
  }
  next.add(FilterBarSort(key, ascending));
  while (next.length > maxSorts) {
    next.removeAt(0);
  }
  return next;
}

/// The sort picker: every field with an up and a down arrow. A field with an
/// arrow on is part of the sort; the number says its priority when there are
/// several. Changes are reported at once (the owner re-queries the database).
class SortPanel extends StatefulWidget {
  const SortPanel({
    super.key,
    required this.options,
    required this.sorts,
    required this.onChanged,
    this.maxSorts = 2,
  });

  final List<FilterBarSortOption> options;
  final List<FilterBarSort> sorts;
  final ValueChanged<List<FilterBarSort>> onChanged;
  final int maxSorts;

  @override
  State<SortPanel> createState() => _SortPanelState();
}

class _SortPanelState extends State<SortPanel> {
  late List<FilterBarSort> _sorts = [...widget.sorts];

  void _press(String key, bool ascending) {
    final next = toggleSort(_sorts, key, ascending, maxSorts: widget.maxSorts);
    setState(() => _sorts = next);
    widget.onChanged(next);
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: context.ui.padding.all(AppSpacing.xs),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: context.ui.padding.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          child: AppText(
            CatalogUiKeys.sortBy,
            type: AppTextType.labelMedium,
            color: context.ui.theme.colors.onSurfaceVariant,
          ),
        ),
        for (final option in widget.options)
          _row(context, option),
      ],
    ),
  );

  Widget _row(BuildContext context, FilterBarSortOption option) {
    final index = _sorts.indexWhere((s) => s.key == option.key);
    final active = index >= 0 ? _sorts[index] : null;
    final colors = context.ui.theme.colors;
    return Padding(
      padding: context.ui.padding.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: [
          Expanded(
            child: AppText(
              option.label,
              color: active == null ? colors.onSurface : colors.primary,
              weight: active == null ? null : FontWeight.w600,
            ),
          ),
          if (active != null && _sorts.length > 1) ...[
            AppText.raw(
              '${index + 1}',
              type: AppTextType.labelSmall,
              color: colors.primary,
            ),
            context.ui.spacing.gap(AppSpacing.sm, axis: Axis.horizontal),
          ],
          _ArrowButton(
            icon: AppIcons.sortAscending,
            label: CatalogUiKeys.sortAscendingLabel,
            on: active?.ascending == true,
            onTap: () => _press(option.key, true),
          ),
          context.ui.spacing.gap(AppSpacing.xs, axis: Axis.horizontal),
          _ArrowButton(
            icon: AppIcons.sortDescending,
            label: CatalogUiKeys.sortDescendingLabel,
            on: active?.ascending == false,
            onTap: () => _press(option.key, false),
          ),
        ],
      ),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({
    required this.icon,
    required this.label,
    required this.on,
    required this.onTap,
  });

  final AppIconData icon;
  final AppKey label;
  final bool on;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final saas = context.ui.theme.saasColors;
    final radius = AppSurfaceShape.control.circular(context);
    final text = label.tr(context: context);
    return Tooltip(
      message: text,
      child: Semantics(
        button: true,
        selected: on,
        label: text,
        excludeSemantics: true,
        onTap: onTap,
        child: Material(
          color: on ? saas.selected : Colors.transparent,
          borderRadius: radius,
          child: InkWell(
            borderRadius: radius,
            onTap: onTap,
            child: SizedBox.square(
              dimension: context.ui.size.width(AppComponentSize.small),
              child: Center(
                child: AppIcon(
                  icon,
                  size: AppIconSize.md,
                  color: on
                      ? saas.onSelected
                      : context.ui.theme.colors.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
