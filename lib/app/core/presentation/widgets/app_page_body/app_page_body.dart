import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/engine/screen_engine.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';

/// Frame of one shell page: responsive padding, a centred maximum content
/// width and a single vertical scroll for the whole page.
///
/// Every page template wraps its content here, so a feature screen never
/// chooses its own padding, max width or scroll behaviour. [child] is laid out
/// with an unbounded height: do not place `Expanded`/`Flexible` or an
/// unbounded-height scrollable directly inside it (use a shrink-wrapped list or
/// a widget that supports unbounded height, such as `AppDataTable`).
class AppPageBody extends StatelessWidget {
  const AppPageBody({super.key, required this.child, this.controller});

  final Widget child;

  /// Optional controller for the page scroll (e.g. to scroll to top).
  final ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: controller,
      padding: context.ui.padding.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      child: Align(
        alignment: AlignmentDirectional.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: ScreenEngine.maxContentWidth(context),
          ),
          child: child,
        ),
      ),
    );
  }
}
