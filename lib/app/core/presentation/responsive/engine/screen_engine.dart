// ─────────────────────────────────────────────────────────────────
// screen_engine.dart
// Layer 0 — كشف نوع الشاشة والاتجاه والأبعاد
// لا يُستخدم مباشرة من الـ UI — تستخدمه الطبقات الأخرى
// ─────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/responsive/engine/app_enums.dart';

abstract final class ScreenEngine {
  // ══════════════════════════════════════════════════════════════
  // BREAKPOINTS — المصدر الوحيد لحدود الشاشات في المشروع
  //   desktop : width >= 1200
  //   tablet  : width < 1200 and shortest side >= 600
  //   mobile  : otherwise (phones, in portrait or landscape)
  // ══════════════════════════════════════════════════════════════

  static const double _mobileBreakpoint = 600;
  static const double _tabletBreakpoint = 1200;

  /// Used when no [MediaQuery] is above [context] (for example while the
  /// theme is built above MaterialApp). A common phone size, so the first
  /// frame never throws.
  static const Size fallbackSize = Size(390, 844);

  // ══════════════════════════════════════════════════════════════
  // DIMENSIONS
  // ══════════════════════════════════════════════════════════════

  static Size _size(BuildContext context) =>
      MediaQuery.maybeSizeOf(context) ?? fallbackSize;

  static double screenWidth(BuildContext context, {double rate = 1}) =>
      _size(context).width * rate;

  static double screenHeight(BuildContext context, {double rate = 1}) =>
      _size(context).height * rate;

  static EdgeInsets safeAreaPadding(BuildContext context) =>
      MediaQuery.maybePaddingOf(context) ?? EdgeInsets.zero;

  // ══════════════════════════════════════════════════════════════
  // SCREEN TYPE
  // ══════════════════════════════════════════════════════════════

  /// Desktop is decided by width. Mobile vs tablet is decided by the shortest
  /// side, so a phone in landscape (e.g. 844×390) stays a mobile instead of
  /// being classified as a tablet just because its width passed 600.
  static ScreenType screenType(BuildContext context) {
    final size = _size(context);
    if (size.width >= _tabletBreakpoint) return ScreenType.desktop;
    if (size.shortestSide >= _mobileBreakpoint) return ScreenType.tablet;
    return ScreenType.mobile;
  }

  static bool isMobile(BuildContext context) =>
      screenType(context) == ScreenType.mobile;

  static bool isTablet(BuildContext context) =>
      screenType(context) == ScreenType.tablet;

  static bool isDesktop(BuildContext context) =>
      screenType(context) == ScreenType.desktop;

  // ══════════════════════════════════════════════════════════════
  // ORIENTATION
  // ══════════════════════════════════════════════════════════════

  static bool isPortrait(BuildContext context) {
    final size = _size(context);
    return size.height >= size.width;
  }

  static bool isLandscape(BuildContext context) => !isPortrait(context);

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
