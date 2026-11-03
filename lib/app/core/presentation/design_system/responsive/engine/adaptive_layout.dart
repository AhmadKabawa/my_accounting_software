import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/engine/app_enums.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/engine/screen_engine.dart';

/// Chooses a layout by the width this widget **actually gets**, not by the
/// width of the whole screen.
///
/// With a sidebar or a panel beside it, the content is narrower than the
/// screen, so a decision based on `MediaQuery` would be wrong for the table,
/// the cards or the master-detail inside it.
///
/// Two tools, two questions:
/// - `Rh.builder`: which **device** is this? (the app shell)
/// - `AdaptiveLayout`: how much **room** do I have? (inside screens and panes)
///
/// Only the chosen builder runs. Breakpoints come from
/// [ScreenEngine.screenTypeForWidth]; a missing [tablet] falls back to
/// [mobile], and a missing [desktop] to [tablet].
///
/// ```dart
/// AdaptiveLayout(
///   mobile: (_) => const InvoiceCards(),
///   desktop: (_) => const InvoiceTable(),
/// )
/// ```
class AdaptiveLayout extends StatelessWidget {
  final WidgetBuilder mobile;
  final WidgetBuilder? tablet;
  final WidgetBuilder? desktop;

  const AdaptiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final builder = switch (ScreenEngine.screenTypeForWidth(
        constraints.maxWidth,
      )) {
        ScreenType.mobile => mobile,
        ScreenType.tablet => tablet ?? mobile,
        ScreenType.desktop => desktop ?? tablet ?? mobile,
      };
      return builder(context);
    },
  );
}
