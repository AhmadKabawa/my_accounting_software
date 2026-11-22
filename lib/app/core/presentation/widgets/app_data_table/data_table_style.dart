import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';

/// Every visual value of the data table, resolved for the current context.
///
/// The look (header band, zebra, hover, selected row, radius) comes from the
/// `AppSaasColors` / `AppSurfaceShape` tokens, so it changes in one place.
class DataTableStyle {
  const DataTableStyle(
    this.context, {
    required this.density,
    this.zebra = defaultZebra,
  });

  /// Zebra striping default. On: in wide tables of accounting figures the eye
  /// needs a guide across the row; the stripe is only a quiet tint and the
  /// row text, not color, carries all information. Decision log UI-01.
  static const bool defaultZebra = true;

  final BuildContext context;
  final AppDensity density;
  final bool zebra;

  ColorScheme get colors => context.ui.theme.colors;

  double get rowHeight => density.rowHeight(context.ui.screen.type);
  double get headerHeight => density.headerHeight(context.ui.screen.type);
  double get gap => context.ui.spacing.md;
  EdgeInsets get cellPadding => context.ui.padding.symmetric(
    horizontal: AppSpacing.md,
    vertical: AppSpacing.sm,
  );

  Color get divider => colors.outlineVariant;
  BorderRadius get bandRadius => AppSurfaceShape.tableBand.circular(context);
  BorderRadius get radius => context.ui.radius.md;
  Border get border => Border.all(color: divider);

  Color get headerBackground => context.ui.theme.saasColors.tableHeaderBand;
  Color get headerForeground => context.ui.theme.saasColors.onTableHeader;
  Color get rowHover => context.ui.theme.saasColors.tableRowHover;
  Color get surface => colors.surface;
  Color get selectedRow => colors.primaryContainer;

  /// Background of row [index] (0-based).
  Color rowColor(int index, {required bool selected}) {
    if (selected) return selectedRow;
    if (zebra && index.isOdd) return context.ui.theme.saasColors.tableZebra;
    return Colors.transparent;
  }
}
