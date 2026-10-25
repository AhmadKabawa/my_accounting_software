// ─────────────────────────────────────────────────────────────────
// screen_engine.dart
// Layer 0 — كشف نوع الشاشة والاتجاه والأبعاد
// لا يُستخدم مباشرة من الـ UI — تستخدمه الطبقات الأخرى
// ─────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/responsive/engine/app_enums.dart';

abstract final class ScreenEngine {
  // ══════════════════════════════════════════════════════════════
  // BREAKPOINTS
  // ══════════════════════════════════════════════════════════════

  static const double _mobileBreakpoint = 600;
  static const double _tabletBreakpoint = 1200;

  // ══════════════════════════════════════════════════════════════
  // DIMENSIONS
  // ══════════════════════════════════════════════════════════════

  static double screenWidth(BuildContext context, {double rate = 1}) =>
      MediaQuery.sizeOf(context).width * rate;

  static double screenHeight(BuildContext context, {double rate = 1}) =>
      MediaQuery.sizeOf(context).height * rate;

  static EdgeInsets safeAreaPadding(BuildContext context) =>
      MediaQuery.paddingOf(context);

  // ══════════════════════════════════════════════════════════════
  // SCREEN TYPE
  // ══════════════════════════════════════════════════════════════

  static bool isMobile(BuildContext context) =>
      screenWidth(context) < _mobileBreakpoint;

  static bool isTablet(BuildContext context) {
    final w = screenWidth(context);
    return w >= _mobileBreakpoint && w < _tabletBreakpoint;
  }

  static bool isDesktop(BuildContext context) =>
      screenWidth(context) >= _tabletBreakpoint;

  static ScreenType screenType(BuildContext context) {
    if (isDesktop(context)) return ScreenType.desktop;
    if (isTablet(context)) return ScreenType.tablet;
    return ScreenType.mobile;
  }

  // ══════════════════════════════════════════════════════════════
  // ORIENTATION
  // ══════════════════════════════════════════════════════════════

  static bool isPortrait(BuildContext context) =>
      MediaQuery.orientationOf(context) == Orientation.portrait;

  static bool isLandscape(BuildContext context) =>
      MediaQuery.orientationOf(context) == Orientation.landscape;

  static AppOrientation orientation(BuildContext context) =>
      isPortrait(context) ? AppOrientation.portrait : AppOrientation.landscape;

  // ══════════════════════════════════════════════════════════════
  // MAX CONTENT WIDTH
  // ══════════════════════════════════════════════════════════════

  static double maxContentWidth(BuildContext context) =>
      switch (screenType(context)) {
        ScreenType.desktop => 1200,
        ScreenType.tablet => 720,
        ScreenType.mobile => double.infinity,
      };
}
