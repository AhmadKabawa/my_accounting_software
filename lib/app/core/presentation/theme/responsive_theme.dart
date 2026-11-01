import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/styles/styles_extension.dart';
import 'package:accounting_software/app/core/presentation/theme/build_theme.dart';

/// Makes the app theme responsive.
///
/// [AppTheme] is built without a BuildContext (the theme is created before
/// MaterialApp, so there is no MediaQuery yet) and therefore holds the mobile
/// baseline sizes. Put this widget in `MaterialApp.builder`, where a
/// MediaQuery and the resolved light/dark [Theme] already exist: it rebuilds
/// the theme with the font sizes and navigation bar height of the current
/// screen, and again whenever the screen size or text scale changes.
class ResponsiveTheme extends StatelessWidget {
  const ResponsiveTheme({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: buildTheme(
        colorScheme: Theme.of(context).colorScheme,
        resolve: (style) => style.resolve(context),
        navigationBarHeight: context.uiStyles.navbar.height,
      ),
      child: child,
    );
  }
}
