part of '../app_enums.dart';

// ═══════════════════════════════════════════════════════════════════
// LAYOUT GRID TOKEN
// ═══════════════════════════════════════════════════════════════════

/// The page grid of a device class: [columns], the outer [margin] and the
/// [gutter] between columns.
///
/// | device  | columns | margin | gutter |
/// | ------- | ------- | ------ | ------ |
/// | phone   | 4       | 16     | 12     |
/// | tablet  | 8       | 24     | 16     |
/// | desktop | 12      | 32     | 24     |
///
/// ```dart
/// final grid = AppGrid.of(context);
/// padding: EdgeInsets.symmetric(horizontal: grid.margin)
/// ```
class AppGrid {
  const AppGrid({
    required this.columns,
    required this.margin,
    required this.gutter,
  });

  final int columns;
  final double margin;
  final double gutter;

  static const mobile = AppGrid(columns: 4, margin: 16, gutter: 12);
  static const tablet = AppGrid(columns: 8, margin: 24, gutter: 16);
  static const desktop = AppGrid(columns: 12, margin: 32, gutter: 24);

  static AppGrid forType(ScreenType type) => switch (type) {
    ScreenType.mobile => mobile,
    ScreenType.tablet => tablet,
    ScreenType.desktop => desktop,
  };

  static AppGrid of(BuildContext context) =>
      forType(ScreenEngine.screenType(context));
}
