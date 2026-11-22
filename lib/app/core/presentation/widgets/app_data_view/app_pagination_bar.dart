import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/foundation/config/app_config.dart';
import 'package:accounting_software/app/core/localization/keys/catalog_ui_keys.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_searchable_dropdown/searchable_dropdown.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';

/// Page numbers to show for [page] of [lastPage]: `null` stands for an
/// ellipsis. Always the first and last page and a window around the current
/// one; every page when there are at most [maxFull].
List<int?> paginationItems(int page, int lastPage, {int maxFull = 7}) {
  if (lastPage <= maxFull) return [for (var i = 1; i <= lastPage; i++) i];
  final current = page.clamp(1, lastPage);
  final pages = <int>{1, lastPage, current - 1, current, current + 1}
    ..removeWhere((p) => p < 1 || p > lastPage);
  final sorted = pages.toList()..sort();
  final items = <int?>[];
  for (var i = 0; i < sorted.length; i++) {
    if (i > 0 && sorted[i] - sorted[i - 1] > 1) items.add(null);
    items.add(sorted[i]);
  }
  return items;
}

/// "Showing X of Y" at the start, page numbers (current one highlighted) at
/// the end. On a phone: the same count and a "load more" button instead of
/// numbers. Presentation only; the owner changes the page and fetches.
class AppPaginationBar extends StatelessWidget {
  const AppPaginationBar({
    super.key,
    required this.page,
    required this.pageSize,
    required this.totalCount,
    required this.shownCount,
    this.onPageChanged,
    this.onPageSizeChanged,
    this.hasMore = false,
    this.onLoadMore,
    this.mobile = false,
  });

  final int page;
  final int pageSize;
  final int totalCount;
  final int shownCount;
  final ValueChanged<int>? onPageChanged;
  final ValueChanged<int>? onPageSizeChanged;
  final bool hasMore;
  final VoidCallback? onLoadMore;
  final bool mobile;

  int get _lastPage => totalCount == 0 ? 1 : (totalCount / pageSize).ceil();

  @override
  Widget build(BuildContext context) {
    final summary = AppText.raw(
      CatalogUiKeys.showingOf.tr(
        context: context,
        namedArgs: {
          'shown': shownCount.toString(),
          'total': totalCount.toString(),
        },
      ),
      type: AppTextType.bodySmall,
      color: context.ui.theme.colors.onSurfaceVariant,
    );
    if (mobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(child: summary),
          if (hasMore && onLoadMore != null) ...[
            context.ui.spacing.gap(AppSpacing.sm),
            AppButton(
              CatalogUiKeys.loadMore,
              variant: AppButtonVariant.outlined,
              onPressed: onLoadMore,
            ),
          ],
        ],
      );
    }
    // Always shown with a page callback: one page reads "‹ 1 ›" (1 chosen).
    final showNumbers = onPageChanged != null;
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: context.ui.spacing.md,
      runSpacing: context.ui.spacing.sm,
      children: [
        summary,
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onPageSizeChanged != null)
              SizedBox(
                width: context.ui.size.width(AppComponentSize.filterControlWidth),
                child: SearchableDropdown<int>(
                  options: AppConfig.pageSizeOptions,
                  labelKey: CatalogUiKeys.rowsPerPage,
                  optionLabel: (value) => value.toString(),
                  value: pageSize,
                  clearable: false,
                  onChanged: (value) {
                    if (value != null) onPageSizeChanged!(value);
                  },
                ),
              ),
            if (showNumbers) ...[
              _PageButton.icon(
                icon: AppIcons.chevronStart,
                label: CatalogUiKeys.previousPage,
                onTap: page > 1 ? () => onPageChanged!(page - 1) : null,
              ),
              for (final item in paginationItems(page, _lastPage))
                item == null
                    ? const _Ellipsis()
                    : _PageButton.number(
                        number: item,
                        selected: item == page,
                        onTap: () => onPageChanged!(item),
                      ),
              _PageButton.icon(
                icon: AppIcons.chevronEnd,
                label: CatalogUiKeys.nextPage,
                onTap: page < _lastPage ? () => onPageChanged!(page + 1) : null,
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _Ellipsis extends StatelessWidget {
  const _Ellipsis();

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: context.ui.size.width(AppComponentSize.small),
    child: Center(
      child: AppText.raw(
        '…',
        color: context.ui.theme.colors.onSurfaceVariant,
      ),
    ),
  );
}

class _PageButton extends StatelessWidget {
  const _PageButton.number({
    required int this.number,
    required this.selected,
    required this.onTap,
  }) : icon = null,
       label = null;

  const _PageButton.icon({
    required AppIconData this.icon,
    required AppKey this.label,
    required this.onTap,
  }) : number = null,
       selected = false;

  final int? number;
  final AppIconData? icon;
  final AppKey? label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final saas = context.ui.theme.saasColors;
    final colors = context.ui.theme.colors;
    final radius = AppSurfaceShape.control.circular(context);
    final enabled = onTap != null;
    final foreground = selected
        ? saas.onSelected
        : enabled
        ? colors.onSurface
        : colors.onSurfaceVariant;
    final text = number != null
        ? CatalogUiKeys.pageNumber.tr(
            context: context,
            namedArgs: {'page': number.toString()},
          )
        : label!.tr(context: context);
    return Padding(
      padding: EdgeInsetsDirectional.only(start: context.ui.spacing.xs),
      child: Semantics(
        button: true,
        enabled: enabled,
        selected: selected,
        label: text,
        excludeSemantics: true,
        child: Material(
          color: selected ? saas.selected : Colors.transparent,
          borderRadius: radius,
          child: InkWell(
            borderRadius: radius,
            onTap: onTap,
            child: SizedBox.square(
              dimension: context.ui.size.width(AppComponentSize.small),
              child: Center(
                child: number != null
                    ? AppText.raw(
                        number.toString(),
                        type: AppTextType.labelMedium,
                        color: foreground,
                      )
                    : AppIcon(icon!, size: AppIconSize.md, color: foreground),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
