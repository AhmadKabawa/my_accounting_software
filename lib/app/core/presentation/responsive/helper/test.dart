// // ─────────────────────────────────────────────────────────────────
// // responsive_system_complete.dart
// // 
// // ✅ ميزات:
// // 1. Tokens اختيارية (adaptive) أو ثابتة (fixed) أو بدون scale
// // 2. جميع الدوال: spacing, padding, gap, size, font, radius, etc
// // 3. Directional support (start/end/RTL)
// // 4. Widget selection, Grid helpers
// // 5. تقسيم الكود إلى files صغيرة + معايير واضحة
// // ─────────────────────────────────────────────────────────────────

// import 'package:flutter/material.dart';
// import 'package:accounting_software/app/core/presentation/responsive/engine/app_enums.dart';

// // ═══════════════════════════════════════════════════════════════════
// // LAYER 0 — INTERNAL ENGINES (DO NOT USE DIRECTLY)
// // ═══════════════════════════════════════════════════════════════════

// abstract final class _ScreenEngine {
//   static const double _mobileBreakpoint = 600;
//   static const double _tabletBreakpoint = 1200;

//   static double screenWidth(BuildContext context) =>
//       MediaQuery.sizeOf(context).width;

//   static double screenHeight(BuildContext context) =>
//       MediaQuery.sizeOf(context).height;

//   static bool isMobile(BuildContext context) =>
//       screenWidth(context) < _mobileBreakpoint;

//   static bool isTablet(BuildContext context) {
//     final w = screenWidth(context);
//     return w >= _mobileBreakpoint && w < _tabletBreakpoint;
//   }

//   static bool isDesktop(BuildContext context) =>
//       screenWidth(context) >= _tabletBreakpoint;

//   static ScreenType  screenType(BuildContext context) {
//     if (isDesktop(context)) return ScreenType.desktop;
//     if (isTablet(context)) return ScreenType.tablet;
//     return ScreenType.mobile;
//   }

//   static bool isLandscape(BuildContext context) =>
//       MediaQuery.orientationOf(context) == Orientation.landscape;

//   static bool isPortrait(BuildContext context) =>
//       MediaQuery.orientationOf(context) == Orientation.portrait;
// }

// abstract final class _ScaleEngine {
//   static const Map<ScreenType, double> _baseWidths = {
//     ScreenType.mobile: 375,
//     ScreenType.tablet: 768,
//     ScreenType.desktop: 1280,
//   };

//   static double scale(
//     BuildContext context, {
//     required double designValue,
//     required double minValue,
//     required double maxValue,
//   }) {
//     if (designValue == double.infinity) return double.infinity;

//     final screenType = _ScreenEngine.screenType(context);
//     final baseWidth = _baseWidths[screenType]!;
//     final screenWidth = _ScreenEngine.screenWidth(context);
    
//     final ratio = screenWidth / baseWidth;
//     final raw = designValue * ratio;

//     return raw.clamp(minValue, maxValue);
//   }

//   static double scaleFont(
//     BuildContext context, {
//     required double designValue,
//     required double minValue,
//     required double maxValue,
//     bool respectTextScaler = true,
//   }) {
//     final scaled = scale(
//       context,
//       designValue: designValue,
//       minValue: minValue,
//       maxValue: maxValue,
//     );

//     if (!respectTextScaler) return scaled;

//     final textScaler = MediaQuery.textScalerOf(context);
//     return textScaler.clamp(maxScaleFactor: 1.3).scale(scaled);
//   }
// }

// // ═══════════════════════════════════════════════════════════════════
// // LAYER 1 — RESPONSIVE CORE (3 MODES)
// // ═══════════════════════════════════════════════════════════════════

// /// Responsive mode: how to handle scaling
// enum ResponsiveMode {
//   /// Value changes per screen type + scales with width
//   /// Default: R.spacing(ctx, AppSpacing.md)
//   adaptive,

//   /// Value changes per screen type BUT no scale
//   /// Use: R.spacingAdaptiveOnly(ctx, AppSpacing.md)
//   adaptiveOnly,

//   /// Fixed value from mobile — no adaptive, no scale
//   /// Use: R.spacingFixed(ctx, AppSpacing.md)
//   fixed,
// }

// typedef R = Responsive;

// /// Single entry point for all responsive needs
// /// 
// /// Three modes: adaptive (default), adaptiveOnly, fixed
// /// 
// /// ```dart
// /// // Mode 1: Adaptive (scales with screen width)
// /// R.spacing(ctx, AppSpacing.md)
// /// 
// /// // Mode 2: Adaptive only (different per breakpoint, no scale)
// /// R.spacingAdaptiveOnly(ctx, AppSpacing.md)
// /// 
// /// // Mode 3: Fixed (always mobile value)
// /// R.spacingFixed(ctx, AppSpacing.md)
// /// ```
// abstract final class Responsive {
  
//   // ══════════════════════════════════════════════════════════════
//   // SPACING (3 MODES)
//   // ══════════════════════════════════════════════════════════════

//   /// Adaptive + Scale (DEFAULT)
//   /// Changes per breakpoint AND scales with screen width
//   static double spacing(BuildContext context, AppSpacing token) {
//     final screenType = _ScreenEngine.screenType(context);
//     final value = token.resolve(screenType);
    
//     return _ScaleEngine.scale(
//       context,
//       designValue: value,
//       minValue: AppSpacing.xs.resolve(screenType),
//       maxValue: AppSpacing.giant.resolve(screenType),
//     );
//   }

//   /// Adaptive only (NO SCALE)
//   /// Changes per breakpoint but no scaling with screen width
//   /// Use for: fixed grid gaps, structural spacing
//   static double spacingAdaptiveOnly(BuildContext context, AppSpacing token) {
//     return token.resolve(_ScreenEngine.screenType(context));
//   }

//   /// Fixed (NO ADAPTIVE, NO SCALE)
//   /// Always returns mobile value
//   /// Use for: badge sizes, tiny details that must stay constant
//   static double spacingFixed(BuildContext context, AppSpacing token) {
//     return token.mobile;
//   }

//   // ══════════════════════════════════════════════════════════════
//   // FONT (3 MODES)
//   // ══════════════════════════════════════════════════════════════

//   static double font(
//     BuildContext context,
//     AppFontSize token, {
//     bool respectTextScaler = true,
//   }) {
//     final screenType = _ScreenEngine.screenType(context);
//     final value = token.resolve(screenType);
//     return _ScaleEngine.scaleFont(
//       context,
//       designValue: value,
//       minValue: AppFontSize.xs.resolve(screenType),
//       maxValue: AppFontSize.display.resolve(screenType),
//       respectTextScaler: respectTextScaler,
//     );
//   }

//   static double fontAdaptiveOnly(
//     BuildContext context,
//     AppFontSize token, {
//     bool respectTextScaler = true,
//   }) {
//     final value = token.resolve(_ScreenEngine.screenType(context));
//     if (!respectTextScaler) return value;
    
//     final scaler = MediaQuery.textScalerOf(context);
//     return scaler.clamp(maxScaleFactor: 1.3).scale(value);
//   }

//   static double fontFixed(BuildContext context, AppFontSize token) {
//     return token.mobile;
//   }

//   // ══════════════════════════════════════════════════════════════
//   // TEXT STYLE
//   // ══════════════════════════════════════════════════════════════

//   static TextStyle textStyle(
//     BuildContext context,
//     AppFontSize fontSize, {
//     FontWeight? weight,
//     Color? color,
//     double? height,
//     double? letterSpacing,
//     bool respectTextScaler = true,
//   }) {
//     return TextStyle(
//       fontSize: font(context, fontSize, respectTextScaler: respectTextScaler),
//       fontWeight: weight,
//       color: color,
//       height: height,
//       letterSpacing: letterSpacing,
//     );
//   }

//   // ══════════════════════════════════════════════════════════════
//   // RADIUS (3 MODES)
//   // ══════════════════════════════════════════════════════════════

//   static double radius(BuildContext context, AppRadius token) {
//     if (token == AppRadius.full) return double.infinity;
    
//     final screenType = _ScreenEngine.screenType(context);
//     final value = token.resolve(screenType);
    
//     return _ScaleEngine.scale(
//       context,
//       designValue: value,
//       minValue: AppRadius.xs.resolve(screenType),
//       maxValue: AppRadius.full.resolve(screenType),
//     );
//   }

//   static double radiusAdaptiveOnly(BuildContext context, AppRadius token) {
//     if (token == AppRadius.full) return double.infinity;
//     return token.resolve(_ScreenEngine.screenType(context));
//   }

//   static double radiusFixed(BuildContext context, AppRadius token) {
//     if (token == AppRadius.full) return double.infinity;
//     return token.mobile;
//   }

//   static BorderRadius radiusBorder(BuildContext context, AppRadius token) =>
//       BorderRadius.circular(radius(context, token));

//   // ══════════════════════════════════════════════════════════════
//   // ICON SIZE (3 MODES)
//   // ══════════════════════════════════════════════════════════════

//   static double iconSize(BuildContext context, AppIconSize token) {
//     final screenType = _ScreenEngine.screenType(context);
//     final value = token.resolve(screenType);
    
//     return _ScaleEngine.scale(
//       context,
//       designValue: value,
//       minValue: AppIconSize.sm.resolve(screenType),
//       maxValue: AppIconSize.huge.resolve(screenType),
//     );
//   }

//   static double iconSizeAdaptiveOnly(BuildContext context, AppIconSize token) {
//     return token.resolve(_ScreenEngine.screenType(context));
//   }

//   static double iconSizeFixed(BuildContext context, AppIconSize token) {
//     return token.mobile;
//   }

//   // ══════════════════════════════════════════════════════════════
//   // COMPONENT SIZE (WIDTH & HEIGHT) (3 MODES)
//   // ══════════════════════════════════════════════════════════════

//   static double componentSize(BuildContext context, AppComponentSize token) {
//     if (token == AppComponentSize.full) return double.infinity;
    
//     final screenType = _ScreenEngine.screenType(context);
//     final value = token.resolve(screenType);
    
//     return _ScaleEngine.scale(
//       context,
//       designValue: value,
//       minValue: AppComponentSize.none.resolve(screenType),
//       maxValue: AppComponentSize.full.resolve(screenType),
//     );
//   }

//   static double componentSizeAdaptiveOnly(
//     BuildContext context,
//     AppComponentSize token,
//   ) {
//     if (token == AppComponentSize.full) return double.infinity;
//     return token.resolve(_ScreenEngine.screenType(context));
//   }

//   static double componentSizeFixed(BuildContext context, AppComponentSize token) {
//     if (token == AppComponentSize.full) return double.infinity;
//     return token.mobile;
//   }

//   // ══════════════════════════════════════════════════════════════
//   // CONVENIENCE: SIZE, WIDTH, HEIGHT
//   // ══════════════════════════════════════════════════════════════

//   static double size(BuildContext context, AppComponentSize token) =>
//       componentSize(context, token);

//   static double width(BuildContext context, AppComponentSize token) =>
//       componentSize(context, token);

//   static double height(BuildContext context, AppComponentSize token) =>
//       componentSize(context, token);

//   // ══════════════════════════════════════════════════════════════
//   // PADDING (absolute: left/right/top/bottom)
//   // ══════════════════════════════════════════════════════════════

//   static EdgeInsets padding(
//     BuildContext context,
//     AppSpacing left,
//     AppSpacing right,
//     AppSpacing top,
//     AppSpacing bottom,
//   ) {
//     return EdgeInsets.only(
//       left: spacing(context, left),
//       right: spacing(context, right),
//       top: spacing(context, top),
//       bottom: spacing(context, bottom),
//     );
//   }

//   /// Symmetric padding: horizontal and vertical
//   static EdgeInsets paddingSymmetric(
//     BuildContext context, {
//     required AppSpacing horizontal,
//     required AppSpacing vertical,
//   }) {
//     return EdgeInsets.symmetric(
//       horizontal: spacing(context, horizontal),
//       vertical: spacing(context, vertical),
//     );
//   }

//   /// All edges same value
//   static EdgeInsets paddingAll(BuildContext context, AppSpacing value) =>
//       EdgeInsets.all(spacing(context, value));

//   /// Only specific edges (others = none)
//   static EdgeInsets paddingOnly(
//     BuildContext context, {
//     AppSpacing left = AppSpacing.none,
//     AppSpacing right = AppSpacing.none,
//     AppSpacing top = AppSpacing.none,
//     AppSpacing bottom = AppSpacing.none,
//   }) {
//     return EdgeInsets.only(
//       left: spacing(context, left),
//       right: spacing(context, right),
//       top: spacing(context, top),
//       bottom: spacing(context, bottom),
//     );
//   }

//   // ══════════════════════════════════════════════════════════════
//   // PADDING DIRECTIONAL (RTL/LTR SUPPORT)
//   // ══════════════════════════════════════════════════════════════

//   static EdgeInsetsDirectional paddingDirectional(
//     BuildContext context,
//     AppSpacing start,
//     AppSpacing end,
//     AppSpacing top,
//     AppSpacing bottom,
//   ) {
//     return EdgeInsetsDirectional.only(
//       start: spacing(context, start),
//       end: spacing(context, end),
//       top: spacing(context, top),
//       bottom: spacing(context, bottom),
//     );
//   }

//   /// Directional: start/end instead of left/right
//   static EdgeInsetsDirectional paddingDirectionalSymmetric(
//     BuildContext context, {
//     required AppSpacing horizontal,
//     required AppSpacing vertical,
//   }) {
//     return EdgeInsetsDirectional.symmetric(
//       horizontal: spacing(context, horizontal),
//       vertical: spacing(context, vertical),
//     );
//   }

//   static EdgeInsetsDirectional paddingDirectionalAll(
//     BuildContext context,
//     AppSpacing value,
//   ) {
//     final v = spacing(context, value);
//     return EdgeInsetsDirectional.all(v);
//   }

//   // ══════════════════════════════════════════════════════════════
//   // GAP (Flexible spacing widget for Row/Column)
//   // ══════════════════════════════════════════════════════════════

//   /// Gap widget that detects axis automatically
//   static Widget gap(BuildContext context, AppSpacing token) =>
//       Gap(spacing(context, token));

//   /// Gap with explicit axis
//   static Widget gapAxis(
//     BuildContext context,
//     AppSpacing token,
//     Axis axis,
//   ) =>
//       Gap(spacing(context, token), axis: axis);

//   /// Expanding gap (like Spacer)
//   static Widget gapExpand() => const Gap.expand();

//   // ══════════════════════════════════════════════════════════════
//   // ADAPTIVE: Different values per breakpoint
//   // ══════════════════════════════════════════════════════════════

//   /// Get different spacing values per screen type
//   static double responsiveSpacing(
//     BuildContext context, {
//     required AppSpacing mobile,
//     AppSpacing? tablet,
//     AppSpacing? desktop,
//   }) {
//     final screenType = _ScreenEngine.screenType(context);
//     final token = switch (screenType) {
//       ScreenType.desktop => desktop ?? tablet ?? mobile,
//       ScreenType.tablet => tablet ?? mobile,
//       ScreenType.mobile => mobile,
//     };
//     return spacing(context, token);
//   }

//   /// Different font sizes per breakpoint
//   static double responsiveFont(
//     BuildContext context, {
//     required AppFontSize mobile,
//     AppFontSize? tablet,
//     AppFontSize? desktop,
//     bool respectTextScaler = true,
//   }) {
//     final screenType = _ScreenEngine.screenType(context);
//     final token = switch (screenType) {
//       ScreenType.desktop => desktop ?? tablet ?? mobile,
//       ScreenType.tablet => tablet ?? mobile,
//       ScreenType.mobile => mobile,
//     };
//     return font(context, token, respectTextScaler: respectTextScaler);
//   }

//   /// Different padding per breakpoint
//   static EdgeInsets responsivePadding(
//     BuildContext context, {
//     required AppSpacing mobile,
//     AppSpacing? tablet,
//     AppSpacing? desktop,
//   }) {
//     final value = responsiveSpacing(
//       context,
//       mobile: mobile,
//       tablet: tablet,
//       desktop: desktop,
//     );
//     return EdgeInsets.all(value);
//   }

//   /// Different padding with directional support
//   static EdgeInsetsDirectional responsivePaddingDirectional(
//     BuildContext context, {
//     required AppSpacing mobileStart,
//     required AppSpacing mobileEnd,
//     AppSpacing? tabletStart,
//     AppSpacing? tabletEnd,
//     AppSpacing? desktopStart,
//     AppSpacing? desktopEnd,
//   }) {
//     final start = responsiveSpacing(
//       context,
//       mobile: mobileStart,
//       tablet: tabletStart,
//       desktop: desktopStart,
//     );
//     final end = responsiveSpacing(
//       context,
//       mobile: mobileEnd,
//       tablet: tabletEnd,
//       desktop: desktopEnd,
//     );
//     return EdgeInsetsDirectional.only(start: start, end: end);
//   }

//   // ══════════════════════════════════════════════════════════════
//   // WIDGET SELECTION (Render different widgets per breakpoint)
//   // ══════════════════════════════════════════════════════════════

//   static Widget widget(
//     BuildContext context, {
//     required Widget mobile,
//     Widget? tablet,
//     Widget? desktop,
//   }) {
//     final screenType = _ScreenEngine.screenType(context);
//     return switch (screenType) {
//       ScreenType.desktop => desktop ?? tablet ?? mobile,
//       ScreenType.tablet => tablet ?? mobile,
//       ScreenType.mobile => mobile,
//     };
//   }

//   // ══════════════════════════════════════════════════════════════
//   // GRID HELPERS (crossAxisCount, mainAxisSpacing, etc)
//   // ══════════════════════════════════════════════════════════════

//   static int crossAxisCount(
//     BuildContext context, {
//     int mobile = 2,
//     int tablet = 3,
//     int desktop = 4,
//   }) {
//     final screenType = _ScreenEngine.screenType(context);
//     return switch (screenType) {
//       ScreenType.desktop => desktop,
//       ScreenType.tablet => tablet,
//       ScreenType.mobile => mobile,
//     };
//   }

//   static double gridSpacing(
//     BuildContext context, {
//     AppSpacing mobile = AppSpacing.md,
//     AppSpacing? tablet,
//     AppSpacing? desktop,
//   }) {
//     return responsiveSpacing(
//       context,
//       mobile: mobile,
//       tablet: tablet,
//       desktop: desktop,
//     );
//   }

//   // ══════════════════════════════════════════════════════════════
//   // PERCENTAGE OF SCREEN WIDTH
//   // ══════════════════════════════════════════════════════════════

//   /// Get a percentage of screen width
//   /// Example: R.percentWidth(ctx, 50) = 50% of screen width
//   static double percentWidth(BuildContext context, double percent) {
//     return _ScreenEngine.screenWidth(context) * (percent / 100);
//   }

//   /// Get a percentage of screen height
//   static double percentHeight(BuildContext context, double percent) {
//     return _ScreenEngine.screenHeight(context) * (percent / 100);
//   }

//   // ══════════════════════════════════════════════════════════════
//   // SCREEN DETECTION (if you need conditional logic)
//   // ══════════════════════════════════════════════════════════════

//   static bool isMobile(BuildContext context) =>
//       _ScreenEngine.isMobile(context);

//   static bool isTablet(BuildContext context) =>
//       _ScreenEngine.isTablet(context);

//   static bool isDesktop(BuildContext context) =>
//       _ScreenEngine.isDesktop(context);

//   static ScreenType screenType(BuildContext context) =>
//       _ScreenEngine.screenType(context);

//   static bool isLandscape(BuildContext context) =>
//       _ScreenEngine.isLandscape(context);

//   static bool isPortrait(BuildContext context) =>
//       _ScreenEngine.isPortrait(context);

//   // ══════════════════════════════════════════════════════════════
//   // MAX CONTENT WIDTH (for constraining wide screens)
//   // ══════════════════════════════════════════════════════════════

//   static double maxContentWidth(BuildContext context) =>
//       switch (_ScreenEngine.screenType(context)) {
//         ScreenType.desktop => 1200,
//         ScreenType.tablet => 720,
//         ScreenType.mobile => double.infinity,
//       };

//   // ══════════════════════════════════════════════════════════════
//   // SAFE AREA (system insets: notches, nav bars, etc)
//   // ══════════════════════════════════════════════════════════════

//   static EdgeInsets safeArea(BuildContext context) =>
//       MediaQuery.paddingOf(context);

//   static double safeAreaTop(BuildContext context) =>
//       MediaQuery.paddingOf(context).top;

//   static double safeAreaBottom(BuildContext context) =>
//       MediaQuery.paddingOf(context).bottom;
// }

// // ═══════════════════════════════════════════════════════════════════
// // GAP WIDGET (from your original code)
// // ═══════════════════════════════════════════════════════════════════

// class Gap extends StatelessWidget {
//   final double size;
//   final Axis? axis;
//   final bool expand;

//   const Gap(
//     this.size, {
//     this.axis,
//     this.expand = false,
//     super.key,
//   });

//   const Gap.expand({super.key})
//       : size = 0,
//         axis = null,
//         expand = true;

//   Axis _resolveAxis(BuildContext context) {
//     if (axis != null) return axis!;
//     final flex = context.findAncestorWidgetOfExactType<Flex>();
//     return flex?.direction ?? Axis.vertical;
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (expand) return const Spacer();
//     final resolvedAxis = _resolveAxis(context);
//     return resolvedAxis == Axis.vertical
//         ? SizedBox(height: size)
//         : SizedBox(width: size);
//   }
// }

// // ═══════════════════════════════════════════════════════════════════
// // EXTENSIONS (استخدام أسهل عبر BuildContext)
// // ═══════════════════════════════════════════════════════════════════

// extension ResponsiveContextExtension on BuildContext {
//   // Spacing
//   double spacing(AppSpacing token) => R.spacing(this, token);
//   double spacingAdaptiveOnly(AppSpacing token) =>
//       R.spacingAdaptiveOnly(this, token);
//   double spacingFixed(AppSpacing token) => R.spacingFixed(this, token);

//   // Font
//   double font(AppFontSize token, {bool respectTextScaler = true}) =>
//       R.font(this, token, respectTextScaler: respectTextScaler);
//   double fontAdaptiveOnly(AppFontSize token, {bool respectTextScaler = true}) =>
//       R.fontAdaptiveOnly(this, token, respectTextScaler: respectTextScaler);
//   double fontFixed(AppFontSize token) => R.fontFixed(this, token);

//   // TextStyle
//   TextStyle textStyle(
//     AppFontSize fontSize, {
//     FontWeight? weight,
//     Color? color,
//   }) => R.textStyle(this, fontSize, weight: weight, color: color);

//   // Radius
//   double radius(AppRadius token) => R.radius(this, token);
//   double radiusAdaptiveOnly(AppRadius token) =>
//       R.radiusAdaptiveOnly(this, token);
//   double radiusFixed(AppRadius token) => R.radiusFixed(this, token);
//   BorderRadius radiusBorder(AppRadius token) => R.radiusBorder(this, token);

//   // Icon Size
//   double iconSize(AppIconSize token) => R.iconSize(this, token);
//   double iconSizeAdaptiveOnly(AppIconSize token) =>
//       R.iconSizeAdaptiveOnly(this, token);
//   double iconSizeFixed(AppIconSize token) => R.iconSizeFixed(this, token);

//   // Component Size
//   double componentSize(AppComponentSize token) =>
//       R.componentSize(this, token);
//   double size(AppComponentSize token) => R.size(this, token);
//   double width(AppComponentSize token) => R.width(this, token);
//   double height(AppComponentSize token) => R.height(this, token);

//   // Padding
//   EdgeInsets paddingAll(AppSpacing value) => R.paddingAll(this, value);
//   EdgeInsets paddingSymmetric({
//     required AppSpacing horizontal,
//     required AppSpacing vertical,
//   }) =>
//       R.paddingSymmetric(this, horizontal: horizontal, vertical: vertical);

//   EdgeInsetsDirectional paddingDirectionalAll(AppSpacing value) =>
//       R.paddingDirectionalAll(this, value);

//   // Gap
//   Widget gap(AppSpacing token) => R.gap(this, token);
//   Widget gapExpand() => R.gapExpand();

//   // Percentage
//   double percentWidth(double percent) => R.percentWidth(this, percent);
//   double percentHeight(double percent) => R.percentHeight(this, percent);

//   // Screen detection
//   bool get isMobile => R.isMobile(this);
//   bool get isTablet => R.isTablet(this);
//   bool get isDesktop => R.isDesktop(this);
//   bool get isLandscape => R.isLandscape(this);
//   bool get isPortrait => R.isPortrait(this);
//   ScreenType get screenType => R.screenType(this);

//   // Safe area
//   EdgeInsets get safeArea => R.safeArea(this);
//   double get safeAreaTop => R.safeAreaTop(this);
//   double get safeAreaBottom => R.safeAreaBottom(this);
// }

// // ═══════════════════════════════════════════════════════════════════
// // ENUMS (FOR REFERENCE — IMPORT FROM YOUR app_enums.dart)
// // ═══════════════════════════════════════════════════════════════════

 
// // استخدم من app_enums.dart:
// // - AppSpacing
// // - AppFontSize
// // - AppRadius
// // - AppIconSize
// // - AppComponentSize
// // - AppOrientation


// /*// ─────────────────────────────────────────────────────────────────
// // responsive_system_v2.dart (SIMPLIFIED VERSION)
// // 
// // ✅ طبقتان واضحتان فقط:
// // Layer 0: Detection + Scale engines (NOT exposed)
// // Layer 1: Responsive helpers (PUBLIC API)
// // 
// // ❌ تم حذف:
// // - 3 طبقات إلى واحدة
// // - baseWidth من public API
// // - adaptive/scale parameters من الحالات البسيطة
// // - التعقيد الزائد
// // ─────────────────────────────────────────────────────────────────

// import 'package:flutter/material.dart';

// // ═══════════════════════════════════════════════════════════════════
// // LAYER 0 — ENGINES (INTERNAL USE ONLY)
// // ═══════════════════════════════════════════════════════════════════

// abstract final class _ScreenEngine {
//   static const double _mobileBreakpoint = 600;
//   static const double _tabletBreakpoint = 1200;

//   static double screenWidth(BuildContext context) =>
//       MediaQuery.sizeOf(context).width;

//   static bool isMobile(BuildContext context) =>
//       screenWidth(context) < _mobileBreakpoint;

//   static bool isTablet(BuildContext context) {
//     final w = screenWidth(context);
//     return w >= _mobileBreakpoint && w < _tabletBreakpoint;
//   }

//   static bool isDesktop(BuildContext context) =>
//       screenWidth(context) >= _tabletBreakpoint;

//   static ScreenType screenType(BuildContext context) {
//     if (isDesktop(context)) return ScreenType.desktop;
//     if (isTablet(context)) return ScreenType.tablet;
//     return ScreenType.mobile;
//   }

//   static bool isLandscape(BuildContext context) =>
//       MediaQuery.orientationOf(context) == Orientation.landscape;
// }

// abstract final class _ScaleEngine {
//   /// موحد للجميع: mobile=375, tablet=768, desktop=1280
//   /// ❌ لا baseWidth override — أبسط بكثير
//   static const Map<ScreenType, double> _baseWidths = {
//     ScreenType.mobile: 375,
//     ScreenType.tablet: 768,
//     ScreenType.desktop: 1280,
//   };

//   static double scale(
//     BuildContext context, {
//     required double designValue,
//     required double minValue,
//     required double maxValue,
//   }) {
//     if (designValue == double.infinity) return double.infinity;

//     final screenType = _ScreenEngine.screenType(context);
//     final baseWidth = _baseWidths[screenType]!;
//     final screenWidth = _ScreenEngine.screenWidth(context);
    
//     final ratio = screenWidth / baseWidth;
//     final raw = designValue * ratio;

//     return raw.clamp(minValue, maxValue);
//   }

//   static double scaleFont(
//     BuildContext context, {
//     required double designValue,
//     required double minValue,
//     required double maxValue,
//     bool respectTextScaler = true,
//   }) {
//     final scaled = scale(
//       context,
//       designValue: designValue,
//       minValue: minValue,
//       maxValue: maxValue,
//     );

//     if (!respectTextScaler) return scaled;

//     final textScaler = MediaQuery.textScalerOf(context);
//     // اللي بتستاهل: max 1.3× 
//     return textScaler.clamp(maxScaleFactor: 1.3).scale(scaled);
//   }
// }

// // ═══════════════════════════════════════════════════════════════════
// // LAYER 1 — PUBLIC API (USE THIS ONLY)
// // ═══════════════════════════════════════════════════════════════════

// /// Single entry point for responsive design
// /// 
// /// **Examples:**
// /// ```dart
// /// // ✅ Simple spacing
// /// SizedBox(height: Responsive.spacing(ctx, AppSpacing.md))
// /// 
// /// // ✅ Padding
// /// Padding(
// ///   padding: EdgeInsets.all(Responsive.spacing(ctx, AppSpacing.lg)),
// ///   child: child,
// /// )
// /// 
// /// // ✅ Font
// /// Text(
// ///   'Hello',
// ///   style: TextStyle(
// ///     fontSize: Responsive.font(ctx, AppFontSize.lg),
// ///   ),
// /// )
// /// 
// /// // ✅ Responsive padding per breakpoint
// /// Padding(
// ///   padding: Responsive.responsivePadding(
// ///     ctx,
// ///     mobile: AppSpacing.md,
// ///     tablet: AppSpacing.lg,
// ///     desktop: AppSpacing.xl,
// ///   ),
// /// )
// /// ```
// typedef R = Responsive;

// abstract final class Responsive {
  
//   // ══════════════════════════════════════════════════════════════
//   // BASIC — 90% من الاستخدام يكون هنا
//   // ══════════════════════════════════════════════════════════════

//   /// Returns responsive spacing value that scales with screen width
//   static double spacing(BuildContext context, AppSpacing token) {
//     final screenType = _ScreenEngine.screenType(context);
//     final value = token.resolve(screenType);
    
//     return _ScaleEngine.scale(
//       context,
//       designValue: value,
//       minValue: AppSpacing.xs.resolve(screenType),
//       maxValue: AppSpacing.giant.resolve(screenType),
//     );
//   }

//   /// Returns responsive font size with optional TextScaler respect
//   static double font(
//     BuildContext context,
//     AppFontSize token, {
//     bool respectTextScaler = true,
//   }) {
//     final screenType = _ScreenEngine.screenType(context);
//     final value = token.resolve(screenType);
//     return _ScaleEngine.scaleFont(
//       context,
//       designValue: value,
//       minValue: (token.minValue ?? AppFontSize.xs).resolve(screenType),
//       maxValue: (token.maxValue ?? AppFontSize.display).resolve(screenType),
//       respectTextScaler: respectTextScaler,
//     );
//   }

//   /// Returns responsive text style
//   static TextStyle textStyle(
//     BuildContext context,
//     AppFontSize fontSize, {
//     FontWeight? weight,
//     Color? color,
//     double? height,
//     double? letterSpacing,
//     bool respectTextScaler = true,
//   }) {
//     return TextStyle(
//       fontSize: font(context, fontSize, respectTextScaler: respectTextScaler),
//       fontWeight: weight,
//       color: color,
//       height: height,
//       letterSpacing: letterSpacing,
//     );
//   }

//   /// Returns responsive radius
//   static double radius(BuildContext context, AppRadius token) {
//     if (token == AppRadius.full) return double.infinity;
    
//     final screenType = _ScreenEngine.screenType(context);
//     final value = token.resolve(screenType);
    
//     return _ScaleEngine.scale(
//       context,
//       designValue: value,
//       minValue: (token.minValue ?? AppRadius.none).resolve(screenType),
//       maxValue: (token.maxValue ?? AppRadius.full).resolve(screenType),
//     );
//   }

//   /// Returns responsive border radius
//   static BorderRadius radiusBorder(
//     BuildContext context,
//     AppRadius token,
//   ) {
//     return BorderRadius.circular(radius(context, token));
//   }

//   /// Returns responsive icon size
//   static double iconSize(BuildContext context, AppIconSize token) {
//     final screenType = _ScreenEngine.screenType(context);
//     final value = token.resolve(screenType);
    
//     return _ScaleEngine.scale(
//       context,
//       designValue: value,
//       minValue: (token.minValue ?? AppIconSize.sm).resolve(screenType),
//       maxValue: (token.maxValue ?? AppIconSize.huge).resolve(screenType),
//     );
//   }

//   /// Returns responsive component size (width/height)
//   static double componentSize(BuildContext context, AppComponentSize token) {
//     if (token == AppComponentSize.full) return double.infinity;
    
//     final screenType = _ScreenEngine.screenType(context);
//     final value = token.resolve(screenType);
    
//     return _ScaleEngine.scale(
//       context,
//       designValue: value,
//       minValue: (token.minValue ?? AppComponentSize.none).resolve(screenType),
//       maxValue: (token.maxValue ?? AppComponentSize.full).resolve(screenType),
//     );
//   }

//   // ══════════════════════════════════════════════════════════════
//   // CONVENIENCE — شيء معروف مع قيم محددة مسبقاً
//   // ══════════════════════════════════════════════════════════════

//   /// Standard page horizontal padding
//   /// Mobile: md, Tablet: lg, Desktop: xl
//   static EdgeInsets pagePaddingH(BuildContext context) {
//     final h = responsiveSpacing(
//       context,
//       mobile: AppSpacing.md,
//       tablet: AppSpacing.lg,
//       desktop: AppSpacing.xl,
//     );
//     return EdgeInsets.symmetric(horizontal: h);
//   }

//   /// Standard page vertical padding
//   static EdgeInsets pagePaddingV(BuildContext context) {
//     final v = responsiveSpacing(
//       context,
//       mobile: AppSpacing.sm,
//       tablet: AppSpacing.md,
//       desktop: AppSpacing.md,
//     );
//     return EdgeInsets.symmetric(vertical: v);
//   }

//   /// Full page padding (both axes)
//   static EdgeInsets pagePadding(BuildContext context) {
//     return EdgeInsets.only(
//       left: responsiveSpacing(
//         context,
//         mobile: AppSpacing.md,
//         tablet: AppSpacing.lg,
//         desktop: AppSpacing.xl,
//       ),
//       right: responsiveSpacing(
//         context,
//         mobile: AppSpacing.md,
//         tablet: AppSpacing.lg,
//         desktop: AppSpacing.xl,
//       ),
//       top: responsiveSpacing(
//         context,
//         mobile: AppSpacing.sm,
//         tablet: AppSpacing.md,
//         desktop: AppSpacing.md,
//       ),
//       bottom: responsiveSpacing(
//         context,
//         mobile: AppSpacing.sm,
//         tablet: AppSpacing.md,
//         desktop: AppSpacing.md,
//       ),
//     );
//   }

//   // ══════════════════════════════════════════════════════════════
//   // ADAPTIVE — قيم مختلفة لكل breakpoint
//   // ══════════════════════════════════════════════════════════════

//   /// Get different spacing values per screen type
//   /// 
//   /// ```dart
//   /// final padding = Responsive.responsiveSpacing(
//   ///   ctx,
//   ///   mobile: AppSpacing.md,
//   ///   tablet: AppSpacing.lg,
//   ///   desktop: AppSpacing.xl,
//   /// );
//   /// ```
//   static double responsiveSpacing(
//     BuildContext context, {
//     required AppSpacing mobile,
//     AppSpacing? tablet,
//     AppSpacing? desktop,
//   }) {
//     final screenType = _ScreenEngine.screenType(context);
//     final token = switch (screenType) {
//       ScreenType.desktop => desktop ?? tablet ?? mobile,
//       ScreenType.tablet => tablet ?? mobile,
//       ScreenType.mobile => mobile,
//     };
//     return spacing(context, token);
//   }

//   /// Get different font sizes per screen type
//   static double responsiveFont(
//     BuildContext context, {
//     required AppFontSize mobile,
//     AppFontSize? tablet,
//     AppFontSize? desktop,
//     bool respectTextScaler = true,
//   }) {
//     final screenType = _ScreenEngine.screenType(context);
//     final token = switch (screenType) {
//       ScreenType.desktop => desktop ?? tablet ?? mobile,
//       ScreenType.tablet => tablet ?? mobile,
//       ScreenType.mobile => mobile,
//     };
//     return font(context, token, respectTextScaler: respectTextScaler);
//   }

//   /// Get different padding per screen type
//   static EdgeInsets responsivePadding(
//     BuildContext context, {
//     required AppSpacing mobile,
//     AppSpacing? tablet,
//     AppSpacing? desktop,
//   }) {
//     final value = responsiveSpacing(
//       context,
//       mobile: mobile,
//       tablet: tablet,
//       desktop: desktop,
//     );
//     return EdgeInsets.all(value);
//   }

//   /// Get different padding with directional support (RTL/LTR)
//   static EdgeInsetsDirectional responsivePaddingDirectional(
//     BuildContext context, {
//     required AppSpacing mobileStart,
//     required AppSpacing mobileEnd,
//     AppSpacing? tabletStart,
//     AppSpacing? tabletEnd,
//     AppSpacing? desktopStart,
//     AppSpacing? desktopEnd,
//   }) {
//     final start = responsiveSpacing(
//       context,
//       mobile: mobileStart,
//       tablet: tabletStart,
//       desktop: desktopStart,
//     );
//     final end = responsiveSpacing(
//       context,
//       mobile: mobileEnd,
//       tablet: tabletEnd,
//       desktop: desktopEnd,
//     );
//     return EdgeInsetsDirectional.only(start: start, end: end);
//   }

//   // ══════════════════════════════════════════════════════════════
//   // FIXED/CLAMPED — حالات متقدمة نادرة
//   // ══════════════════════════════════════════════════════════════

//   /// Fixed value that doesn't scale (base mobile value)
//   /// 
//   /// Use only when you absolutely need a fixed dimension.
//   /// Example: icon badge width should always be exactly 32px
//   static double fixed(AppSpacing token) => token.mobile;

//   /// Clamped spacing (advanced use case)
//   /// 
//   /// Use when you want to scale but within specific bounds
//   static double spacingClamped(
//     BuildContext context,
//     AppSpacing token, {
//     required AppSpacing min,
//     required AppSpacing max,
//   }) {
//     final screenType = _ScreenEngine.screenType(context);
//     final value = token.resolve(screenType);
//     final minVal = min.resolve(screenType);
//     final maxVal = max.resolve(screenType);
    
//     return _ScaleEngine.scale(
//       context,
//       designValue: value,
//       minValue: minVal,
//       maxValue: maxVal,
//     );
//   }

//   // ══════════════════════════════════════════════════════════════
//   // SCREEN DETECTION — ندرة الاستخدام
//   // ══════════════════════════════════════════════════════════════

//   static bool isMobile(BuildContext context) =>
//       _ScreenEngine.isMobile(context);

//   static bool isTablet(BuildContext context) =>
//       _ScreenEngine.isTablet(context);

//   static bool isDesktop(BuildContext context) =>
//       _ScreenEngine.isDesktop(context);

//   static ScreenType screenType(BuildContext context) =>
//       _ScreenEngine.screenType(context);

//   static bool isLandscape(BuildContext context) =>
//       _ScreenEngine.isLandscape(context);
// }

// // ═══════════════════════════════════════════════════════════════════
// // EXTENSIONS — لأولئك الذين يحبون الاختصار
// // ═══════════════════════════════════════════════════════════════════

// extension ResponsiveContextExtension on BuildContext {
//   double spacing(AppSpacing token) =>
//       Responsive.spacing(this, token);

//   double font(AppFontSize token, {bool respectTextScaler = true}) =>
//       Responsive.font(this, token, respectTextScaler: respectTextScaler);

//   TextStyle textStyle(
//     AppFontSize fontSize, {
//     FontWeight? weight,
//     Color? color,
//   }) => Responsive.textStyle(
//     this,
//     fontSize,
//     weight: weight,
//     color: color,
//   );

//   double radius(AppRadius token) => Responsive.radius(this, token);

//   BorderRadius radiusBorder(AppRadius token) =>
//       Responsive.radiusBorder(this, token);

//   double iconSize(AppIconSize token) =>
//       Responsive.iconSize(this, token);

//   double componentSize(AppComponentSize token) =>
//       Responsive.componentSize(this, token);

//   EdgeInsets pagePadding() => Responsive.pagePadding(this);

//   bool get isMobile => Responsive.isMobile(this);
//   bool get isTablet => Responsive.isTablet(this);
//   bool get isDesktop => Responsive.isDesktop(this);
//   ScreenType get screenType => Responsive.screenType(this);
// }

// // ═══════════════════════════════════════════════════════════════════
// // EXAMPLE USAGE
// // ═══════════════════════════════════════════════════════════════════

// /*

// // ✅ الأسلوب الموصى به:
// class ProductCard extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.all(R.spacing(context, AppSpacing.md)),
//       child: Column(
//         children: [
//           Text(
//             'Product Name',
//             style: R.textStyle(
//               context,
//               AppFontSize.lg,
//               weight: FontWeight.bold,
//             ),
//           ),
//           SizedBox(height: R.spacing(context, AppSpacing.sm)),
//           Text('Price'),
//         ],
//       ),
//     );
//   }
// }

// // ✅ استخدام Extensions:
// Padding(
//   padding: EdgeInsets.all(context.spacing(AppSpacing.md)),
//   child: Text('Hello'),
// )

// // ✅ Responsive padding:
// Container(
//   padding: R.responsivePadding(
//     context,
//     mobile: AppSpacing.md,
//     tablet: AppSpacing.lg,
//     desktop: AppSpacing.xl,
//   ),
// )

// // ✅ الاختيار المشروط:
// if (context.isMobile) {
//   // mobile-specific layout
// }

// */ */




/*
// ─────────────────────────────────────────────────────────────────
// responsive_helper.dart
// Layer 2 — Supports three modes:
// 1. Adaptive + Scale (default) - scales according to screen width
// 2. Adaptive only - varies by screen type without scaling
// 3. Scale only - scales mobile baseline value only
// 4. Fixed - fixed value (no adaptive, no scale)
//
// Examples:
//   Rh.spacing(ctx, AppSpacingConfig(size: AppSpacing.md))  // Adaptive + Scale
//   Rh.spacing(ctx, AppSpacingConfig(size: AppSpacing.md), mode: ResponsiveMode.adaptiveOnly)
//   Rh.spacing(ctx, AppSpacingConfig(size: AppSpacing.md), mode: ResponsiveMode.fixed)
//   Rh.spacing(ctx, AppSpacingConfig(size: AppSpacing.md), mode: ResponsiveMode.scaleOnly)
// ─────────────────────────────────────────────────────────────────

export '../engine/app_enums.dart';
export '../engine/app_responsive_configs.dart';

import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/responsive/engine/app_enums.dart';
import 'package:accounting_software/app/core/presentation/responsive/engine/app_gap.dart';
import 'package:accounting_software/app/core/presentation/responsive/engine/app_responsive_configs.dart';
import 'package:accounting_software/app/core/presentation/responsive/engine/scale_engine.dart';
import 'package:accounting_software/app/core/presentation/responsive/engine/screen_engine.dart';

/// 🎯 Responsive mode selection
enum ResponsiveMode {
  /// Fixed value - uses mobile baseline, no adaptation, no scaling
  fixed,

  /// Scale only - scales mobile baseline value based on screen width
  scaleOnly,

  /// Adaptive only - uses different values per screen type without scaling
  adaptiveOnly,

  /// Adaptive + Scale (default) - uses different values per screen type AND scales
  adaptiveScale,
}

// Shortcut for quick usage
typedef Rh = ResponsiveHelper;

abstract final class ResponsiveHelper {
  // ══════════════════════════════════════════════════════════════
  // Helper method to get mobile fixed value
  // ══════════════════════════════════════════════════════════════

  static double _getMobileFixedValue<T extends Enum>(
    T token,
    double Function(T) getMobileValue,
  ) {
    return getMobileValue(token);
  }

  // ══════════════════════════════════════════════════════════════
  // Helper for orientation-aware values
  // ══════════════════════════════════════════════════════════════

  static T _adaptiveValue<T>(
    BuildContext context, {
    required T mobile,
    T? mobileLandscape,
    required T tablet,
    T? tabletLandscape,
    required T desktop,
  }) {
    final screenType = ScreenEngine.screenType(context);
    final orientation = ScreenEngine.orientation(context);

    // Desktop always uses desktop value regardless of orientation
    if (screenType == ScreenType.desktop) {
      return desktop;
    }

    // Tablet with landscape orientation
    if (screenType == ScreenType.tablet && 
        orientation == AppOrientation.landscape &&
        tabletLandscape != null) {
      return tabletLandscape;
    }

    // Mobile with landscape orientation
    if (screenType == ScreenType.mobile && 
        orientation == AppOrientation.landscape &&
        mobileLandscape != null) {
      return mobileLandscape;
    }

    // Default cases
    switch (screenType) {
      case ScreenType.mobile:
        return mobile;
      case ScreenType.tablet:
        return tablet;
      case ScreenType.desktop:
        return desktop;
    }
  }

  // ══════════════════════════════════════════════════════════════
  // FONT
  // ══════════════════════════════════════════════════════════════

  /// Simple font method with minimal parameters
  static double fontSimple(
    BuildContext context,
    AppFontSize size, {
    AppFontSize? min,
    AppFontSize? max,
    bool respectTextScaler = true,
    ResponsiveMode mode = ResponsiveMode.adaptiveScale,
  }) {
    final screenType = ScreenEngine.screenType(context);

    switch (mode) {
      case ResponsiveMode.fixed:
        return size.mobile;

      case ResponsiveMode.scaleOnly:
        return ScaleEngine.scaleFont(
          context,
          designValue: size.mobile,
          configBaseWidth: null,
          minValue: (min ?? AppFontSize.xs).mobile,
          maxValue: (max ?? AppFontSize.display).mobile,
          respectTextScaler: respectTextScaler,
        );

      case ResponsiveMode.adaptiveOnly:
        return size.forType(screenType);

      case ResponsiveMode.adaptiveScale:
        final designValue = size.forType(screenType);
        final minValue = (min ?? AppFontSize.xs).forType(screenType);
        final maxValue = (max ?? AppFontSize.display).forType(screenType);
        return ScaleEngine.scaleFont(
          context,
          designValue: designValue,
          configBaseWidth: null,
          minValue: minValue,
          maxValue: maxValue,
          respectTextScaler: respectTextScaler,
        );
    }
  }

  /// Advanced font method with full config
  static double font(
    BuildContext context,
    AppFontConfig config, {
    bool respectTextScaler = true,
    ResponsiveMode mode = ResponsiveMode.adaptiveScale,
  }) {
    final screenType = ScreenEngine.screenType(context);

    switch (mode) {
      case ResponsiveMode.fixed:
        return config.size.mobile;

      case ResponsiveMode.scaleOnly:
        return ScaleEngine.scaleFont(
          context,
          designValue: config.size.mobile,
          configBaseWidth: config.baseWidth,
          minValue: (config.min ?? AppFontSize.xs).mobile,
          maxValue: (config.max ?? AppFontSize.display).mobile,
          respectTextScaler: respectTextScaler,
        );

      case ResponsiveMode.adaptiveOnly:
        return config.size.forType(screenType);

      case ResponsiveMode.adaptiveScale:
        final designValue = config.size.forType(screenType);
        final minValue = (config.min ?? AppFontSize.xs).forType(screenType);
        final maxValue = (config.max ?? AppFontSize.display).forType(screenType);
        return ScaleEngine.scaleFont(
          context,
          designValue: designValue,
          configBaseWidth: config.baseWidth,
          minValue: minValue,
          maxValue: maxValue,
          respectTextScaler: respectTextScaler,
        );
    }
  }

  // ══════════════════════════════════════════════════════════════
  // TEXT STYLE
  // ══════════════════════════════════════════════════════════════

  static TextStyle textStyle(
    BuildContext context,
    AppFontConfig config, {
    FontWeight? weight,
    Color? color,
    double? height,
    double? letterSpacing,
    bool respectTextScaler = true,
    ResponsiveMode mode = ResponsiveMode.adaptiveScale,
  }) {
    return TextStyle(
      fontSize: font(
        context,
        config,
        respectTextScaler: respectTextScaler,
        mode: mode,
      ),
      fontWeight: weight,
      color: color,
      height: height ?? config.height ?? 1.4,
      letterSpacing: letterSpacing ?? config.letterSpacing,
    );
  }

  // ══════════════════════════════════════════════════════════════
  // SPACING
  // ══════════════════════════════════════════════════════════════

  static double spacing(
    BuildContext context,
    AppSpacingConfig config, {
    ResponsiveMode mode = ResponsiveMode.adaptiveScale,
  }) {
    final screenType = ScreenEngine.screenType(context);

    switch (mode) {
      case ResponsiveMode.fixed:
        return config.size.mobile;

      case ResponsiveMode.scaleOnly:
        return ScaleEngine.scale(
          context,
          designValue: config.size.mobile,
          configBaseWidth: config.baseWidth,
          minValue: (config.min ?? AppSpacing.none).mobile,
          maxValue: (config.max ?? AppSpacing.giant).mobile,
        );

      case ResponsiveMode.adaptiveOnly:
        return config.size.forType(screenType);

      case ResponsiveMode.adaptiveScale:
        return ScaleEngine.scale(
          context,
          designValue: config.size.forType(screenType),
          configBaseWidth: config.baseWidth,
          minValue: (config.min ?? AppSpacing.none).forType(screenType),
          maxValue: (config.max ?? AppSpacing.giant).forType(screenType),
        );
    }
  }

  // ══════════════════════════════════════════════════════════════
  // SIZE (WIDTH & HEIGHT)
  // ══════════════════════════════════════════════════════════════

  static double size(
    BuildContext context,
    AppSizeConfig config, {
    ResponsiveMode mode = ResponsiveMode.adaptiveScale,
  }) {
    final screenType = ScreenEngine.screenType(context);

    switch (mode) {
      case ResponsiveMode.fixed:
        return config.size.mobile;

      case ResponsiveMode.scaleOnly:
        return ScaleEngine.scale(
          context,
          designValue: config.size.mobile,
          configBaseWidth: config.baseWidth,
          minValue: (config.min ?? AppComponentSize.none).mobile,
          maxValue: (config.max ?? AppComponentSize.full).mobile,
        );

      case ResponsiveMode.adaptiveOnly:
        return config.size.forType(screenType);

      case ResponsiveMode.adaptiveScale:
        return ScaleEngine.scale(
          context,
          designValue: config.size.forType(screenType),
          configBaseWidth: config.baseWidth,
          minValue: (config.min ?? AppComponentSize.none).forType(screenType),
          maxValue: (config.max ?? AppComponentSize.full).forType(screenType),
        );
    }
  }

  static double width(
    BuildContext context,
    AppSizeConfig config, {
    ResponsiveMode mode = ResponsiveMode.adaptiveScale,
  }) => size(context, config, mode: mode);

  static double height(
    BuildContext context,
    AppSizeConfig config, {
    ResponsiveMode mode = ResponsiveMode.adaptiveScale,
  }) => size(context, config, mode: mode);

  // ══════════════════════════════════════════════════════════════
  // PADDING (Absolute — left/right)
  // ══════════════════════════════════════════════════════════════

  static double _resolveSpacingValue(
    BuildContext context,
    ScreenType screenType,
    AppSpacing? spacing,
    AppBaseWidth? baseWidth,
    AppSpacing? min,
    AppSpacing? max,
    ResponsiveMode mode,
  ) {
    final effectiveSpacing = spacing ?? AppSpacing.none;

    switch (mode) {
      case ResponsiveMode.fixed:
        return effectiveSpacing.mobile;

      case ResponsiveMode.scaleOnly:
        return ScaleEngine.scale(
          context,
          designValue: effectiveSpacing.mobile,
          configBaseWidth: baseWidth,
          minValue: (min ?? AppSpacing.none).mobile,
          maxValue: (max ?? AppSpacing.giant).mobile,
        );

      case ResponsiveMode.adaptiveOnly:
        return effectiveSpacing.forType(screenType);

      case ResponsiveMode.adaptiveScale:
        return ScaleEngine.scale(
          context,
          designValue: effectiveSpacing.forType(screenType),
          configBaseWidth: baseWidth,
          minValue: (min ?? AppSpacing.none).forType(screenType),
          maxValue: (max ?? AppSpacing.giant).forType(screenType),
        );
    }
  }

  static EdgeInsets padding(
    BuildContext context,
    AppPaddingConfig config, {
    ResponsiveMode mode = ResponsiveMode.adaptiveScale,
  }) {
    final screenType = ScreenEngine.screenType(context);
    return EdgeInsets.only(
      left: _resolveSpacingValue(
        context,
        screenType,
        config.resolvedLeft,
        config.baseWidth,
        config.min,
        config.max,
        mode,
      ),
      right: _resolveSpacingValue(
        context,
        screenType,
        config.resolvedRight,
        config.baseWidth,
        config.min,
        config.max,
        mode,
      ),
      top: _resolveSpacingValue(
        context,
        screenType,
        config.resolvedTop,
        config.baseWidth,
        config.min,
        config.max,
        mode,
      ),
      bottom: _resolveSpacingValue(
        context,
        screenType,
        config.resolvedBottom,
        config.baseWidth,
        config.min,
        config.max,
        mode,
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // PADDING DIRECTIONAL (start/end — RTL support)
  // ══════════════════════════════════════════════════════════════

  static EdgeInsetsDirectional paddingDirectional(
    BuildContext context,
    AppPaddingDirectionalConfig config, {
    ResponsiveMode mode = ResponsiveMode.adaptiveScale,
  }) {
    final screenType = ScreenEngine.screenType(context);
    return EdgeInsetsDirectional.only(
      start: _resolveSpacingValue(
        context,
        screenType,
        config.resolvedStart,
        config.baseWidth,
        config.min,
        config.max,
        mode,
      ),
      end: _resolveSpacingValue(
        context,
        screenType,
        config.resolvedEnd,
        config.baseWidth,
        config.min,
        config.max,
        mode,
      ),
      top: _resolveSpacingValue(
        context,
        screenType,
        config.resolvedTop,
        config.baseWidth,
        config.min,
        config.max,
        mode,
      ),
      bottom: _resolveSpacingValue(
        context,
        screenType,
        config.resolvedBottom,
        config.baseWidth,
        config.min,
        config.max,
        mode,
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // RADIUS
  // ══════════════════════════════════════════════════════════════

  static double _resolveRadiusValue(
    BuildContext context,
    ScreenType screenType,
    AppRadiusConfig config,
    ResponsiveMode mode,
  ) {
    if (config.isPill) return double.infinity;

    switch (mode) {
      case ResponsiveMode.fixed:
        return config.size.mobile;

      case ResponsiveMode.scaleOnly:
        return ScaleEngine.scale(
          context,
          designValue: config.size.mobile,
          configBaseWidth: config.baseWidth,
          minValue: (config.min ?? AppRadius.none).mobile,
          maxValue: (config.max ?? AppRadius.full).mobile,
        );

      case ResponsiveMode.adaptiveOnly:
        return config.size.forType(screenType);

      case ResponsiveMode.adaptiveScale:
        return ScaleEngine.scale(
          context,
          designValue: config.size.forType(screenType),
          configBaseWidth: config.baseWidth,
          minValue: (config.min ?? AppRadius.none).forType(screenType),
          maxValue: (config.max ?? AppRadius.full).forType(screenType),
        );
    }
  }

  static BorderRadius radius(
    BuildContext context,
    AppRadiusConfig config, {
    ResponsiveMode mode = ResponsiveMode.adaptiveScale,
  }) {
    final screenType = ScreenEngine.screenType(context);

    if (config.isPill) return BorderRadius.circular(double.infinity);

    final r = _resolveRadiusValue(context, screenType, config, mode);
    final corner = Radius.circular(r);
    const sharp = Radius.zero;

    if (config.isCircular) return BorderRadius.circular(r);

    return BorderRadius.only(
      topLeft: config.topLeft ? corner : sharp,
      topRight: config.topRight ? corner : sharp,
      bottomLeft: config.bottomLeft ? corner : sharp,
      bottomRight: config.bottomRight ? corner : sharp,
    );
  }

  // ══════════════════════════════════════════════════════════════
  // RADIUS DIRECTIONAL (start/end — RTL support)
  // ══════════════════════════════════════════════════════════════

  static double _resolveRadiusDirectionalValue(
    BuildContext context,
    ScreenType screenType,
    AppRadiusDirectionalConfig config,
    ResponsiveMode mode,
  ) {
    if (config.isPill) return double.infinity;

    switch (mode) {
      case ResponsiveMode.fixed:
        return config.size.mobile;

      case ResponsiveMode.scaleOnly:
        return ScaleEngine.scale(
          context,
          designValue: config.size.mobile,
          configBaseWidth: config.baseWidth,
          minValue: (config.min ?? AppRadius.none).mobile,
          maxValue: (config.max ?? AppRadius.full).mobile,
        );

      case ResponsiveMode.adaptiveOnly:
        return config.size.forType(screenType);

      case ResponsiveMode.adaptiveScale:
        return ScaleEngine.scale(
          context,
          designValue: config.size.forType(screenType),
          configBaseWidth: config.baseWidth,
          minValue: (config.min ?? AppRadius.none).forType(screenType),
          maxValue: (config.max ?? AppRadius.full).forType(screenType),
        );
    }
  }

  static BorderRadiusDirectional radiusDirectional(
    BuildContext context,
    AppRadiusDirectionalConfig config, {
    ResponsiveMode mode = ResponsiveMode.adaptiveScale,
  }) {
    final screenType = ScreenEngine.screenType(context);

    if (config.isPill) {
      return BorderRadiusDirectional.circular(double.infinity);
    }

    final r = _resolveRadiusDirectionalValue(context, screenType, config, mode);
    final corner = Radius.circular(r);
    const sharp = Radius.zero;

    if (config.isCircular) return BorderRadiusDirectional.circular(r);

    return BorderRadiusDirectional.only(
      topStart: config.topStart ? corner : sharp,
      topEnd: config.topEnd ? corner : sharp,
      bottomStart: config.bottomStart ? corner : sharp,
      bottomEnd: config.bottomEnd ? corner : sharp,
    );
  }

  // ══════════════════════════════════════════════════════════════
  // ICON SIZE
  // ══════════════════════════════════════════════════════════════

  static double iconSize(
    BuildContext context,
    AppIconConfig config, {
    ResponsiveMode mode = ResponsiveMode.adaptiveScale,
  }) {
    final screenType = ScreenEngine.screenType(context);

    switch (mode) {
      case ResponsiveMode.fixed:
        return config.size.mobile;

      case ResponsiveMode.scaleOnly:
        return ScaleEngine.scale(
          context,
          designValue: config.size.mobile,
          configBaseWidth: config.baseWidth,
          minValue: (config.min ?? AppIconSize.sm).mobile,
          maxValue: (config.max ?? AppIconSize.huge).mobile,
        );

      case ResponsiveMode.adaptiveOnly:
        return config.size.forType(screenType);

      case ResponsiveMode.adaptiveScale:
        return ScaleEngine.scale(
          context,
          designValue: config.size.forType(screenType),
          configBaseWidth: config.baseWidth,
          minValue: (config.min ?? AppIconSize.sm).forType(screenType),
          maxValue: (config.max ?? AppIconSize.huge).forType(screenType),
        );
    }
  }

  // ══════════════════════════════════════════════════════════════
  // ELEVATION
  // ══════════════════════════════════════════════════════════════

  static double elevation(
    BuildContext context,
    AppElevationConfig config, {
    ResponsiveMode mode = ResponsiveMode.adaptiveScale,
  }) {
    final screenType = ScreenEngine.screenType(context);

    switch (mode) {
      case ResponsiveMode.fixed:
        return config.size.mobile;

      case ResponsiveMode.scaleOnly:
      case ResponsiveMode.adaptiveOnly:
      case ResponsiveMode.adaptiveScale:
        // For elevation, adaptiveOnly and adaptiveScale return the same
        return config.size.forType(screenType);
    }
  }

  // ══════════════════════════════════════════════════════════════
  // GAP
  // ══════════════════════════════════════════════════════════════

  static Gap gapSpace(
    BuildContext context,
    AppSpacingConfig config, {
    Axis? axis,
    ResponsiveMode mode = ResponsiveMode.adaptiveScale,
  }) => Gap(
    spacing(context, config, mode: mode),
    axis: axis,
  );
  // ══════════════════════════════════════════════════════════════
  // WIDGET SELECTION
  // ══════════════════════════════════════════════════════════════

  /// Returns different widgets based on screen type and orientation
  ///
  /// Example:
  /// ```dart
  /// Widget myWidget = Rh.widget(
  ///   context,
  ///   mobile: MobileWidget(),
  ///   mobileLandscape: MobileLandscapeWidget(),
  ///   tablet: TabletWidget(),
  ///   tabletLandscape: TabletLandscapeWidget(),
  ///   desktop: DesktopWidget(),
  ///   mode: ResponsiveMode.adaptiveOnly,
  /// );
  /// ```
  static Widget widget({
    required BuildContext context,
    required Widget mobile,
    Widget? mobileLandscape,
    Widget? tablet,
    Widget? tabletLandscape,
    Widget? desktop,
    ResponsiveMode mode = ResponsiveMode.adaptiveOnly,
  }) {
    switch (mode) {
      case ResponsiveMode.fixed:
        return mobile;

      case ResponsiveMode.scaleOnly:
      case ResponsiveMode.adaptiveOnly:
      case ResponsiveMode.adaptiveScale:
        return _adaptiveValue(
          context,
          mobile: mobile,
          mobileLandscape: mobileLandscape,
          tablet: tablet ?? mobile,
          tabletLandscape: tabletLandscape ?? tablet ?? mobile,
          desktop: desktop ?? tablet ?? mobile,
        );
    }
  }
  
  
  
    static int crossAxisCount(
    BuildContext context, {
    int mobile = 2,
    int mobileLandscape = 3,
    int tablet = 3,
    int tabletLandscape = 4,
    int desktop = 4,
    ResponsiveMode mode = ResponsiveMode.adaptiveOnly,
  }) {
    switch (mode) {
      case ResponsiveMode.fixed:
        return mobile;

      case ResponsiveMode.scaleOnly:
      case ResponsiveMode.adaptiveOnly:
      case ResponsiveMode.adaptiveScale:
        return _adaptiveValue(
          context,
          mobile: mobile,
          mobileLandscape: mobileLandscape,
          tablet: tablet,
          tabletLandscape: tabletLandscape,
          desktop: desktop,
        );
    }
  }

  // ══════════════════════════════════════════════════════════════
  // PAGE PADDING
  // ══════════════════════════════════════════════════════════════

  /// Returns responsive page padding using AppSpacing tokens
  ///
  /// Example:
  /// ```dart
  /// Padding(
  ///   padding: Rh.pagePadding(context),
  ///   child: child,
  /// )
  /// ```
  static EdgeInsets pagePadding(
    BuildContext context, {
    AppSpacing mobileH = AppSpacing.md,
    AppSpacing mobileV = AppSpacing.sm,
    AppSpacing tabletH = AppSpacing.xl,
    AppSpacing tabletV = AppSpacing.md,
    AppSpacing desktopH = AppSpacing.huge,
    AppSpacing desktopV = AppSpacing.md,
    ResponsiveMode mode = ResponsiveMode.adaptiveOnly,
  }) {
    final screenType = ScreenEngine.screenType(context);

    switch (mode) {
      case ResponsiveMode.fixed:
        return EdgeInsets.symmetric(
          horizontal: mobileH.mobile,
          vertical: mobileV.mobile,
        );

      case ResponsiveMode.scaleOnly:
        return EdgeInsets.symmetric(
          horizontal: ScaleEngine.scale(
            context,
            designValue: mobileH.mobile,
            minValue: mobileH.mobile,
            maxValue: desktopH.mobile,
          ),
          vertical: ScaleEngine.scale(
            context,
            designValue: mobileV.mobile,
            minValue: mobileV.mobile,
            maxValue: desktopV.mobile,
          ),
        );

      case ResponsiveMode.adaptiveOnly:
        return _adaptiveValue(
          context,
          mobile: EdgeInsets.symmetric(
            horizontal: mobileH.forType(screenType),
            vertical: mobileV.forType(screenType),
          ),
          mobileLandscape: EdgeInsets.symmetric(
            horizontal: mobileH.forType(screenType),
            vertical: mobileV.forType(screenType),
          ),
          tablet: EdgeInsets.symmetric(
            horizontal: tabletH.forType(screenType),
            vertical: tabletV.forType(screenType),
          ),
          tabletLandscape: EdgeInsets.symmetric(
            horizontal: tabletH.forType(screenType),
            vertical: tabletV.forType(screenType),
          ),
          desktop: EdgeInsets.symmetric(
            horizontal: desktopH.forType(screenType),
            vertical: desktopV.forType(screenType),
          ),
        );

      case ResponsiveMode.adaptiveScale:
        return _adaptiveValue(
          context,
          mobile: EdgeInsets.symmetric(
            horizontal: ScaleEngine.scale(
              context,
              designValue: mobileH.forType(screenType),
              minValue: mobileH.mobile,
              maxValue: desktopH.forType(screenType),
            ),
            vertical: ScaleEngine.scale(
              context,
              designValue: mobileV.forType(screenType),
              minValue: mobileV.mobile,
              maxValue: desktopV.forType(screenType),
            ),
          ),
          mobileLandscape: EdgeInsets.symmetric(
            horizontal: ScaleEngine.scale(
              context,
              designValue: mobileH.forType(screenType),
              minValue: mobileH.mobile,
              maxValue: desktopH.forType(screenType),
            ),
            vertical: ScaleEngine.scale(
              context,
              designValue: mobileV.forType(screenType),
              minValue: mobileV.mobile,
              maxValue: desktopV.forType(screenType),
            ),
          ),
          tablet: EdgeInsets.symmetric(
            horizontal: ScaleEngine.scale(
              context,
              designValue: tabletH.forType(screenType),
              minValue: mobileH.forType(screenType),
              maxValue: desktopH.forType(screenType),
            ),
            vertical: ScaleEngine.scale(
              context,
              designValue: tabletV.forType(screenType),
              minValue: mobileV.forType(screenType),
              maxValue: desktopV.forType(screenType),
            ),
          ),
          tabletLandscape: EdgeInsets.symmetric(
            horizontal: ScaleEngine.scale(
              context,
              designValue: tabletH.forType(screenType),
              minValue: mobileH.forType(screenType),
              maxValue: desktopH.forType(screenType),
            ),
            vertical: ScaleEngine.scale(
              context,
              designValue: tabletV.forType(screenType),
              minValue: mobileV.forType(screenType),
              maxValue: desktopV.forType(screenType),
            ),
          ),
          desktop: EdgeInsets.symmetric(
            horizontal: ScaleEngine.scale(
              context,
              designValue: desktopH.forType(screenType),
              minValue: mobileH.forType(screenType),
              maxValue: desktopH.forType(screenType),
            ),
            vertical: ScaleEngine.scale(
              context,
              designValue: desktopV.forType(screenType),
              minValue: mobileV.forType(screenType),
              maxValue: desktopV.forType(screenType),
            ),
          ),
        );
    }
  }
  }

// ═══════════════════════════════════════════════════════════════════
// EXTENSIONS — Easier usage via BuildContext
// ═══════════════════════════════════════════════════════════════════

extension ResponsiveContextExtension on BuildContext {
  double spacing(
    AppSpacingConfig config, {
    ResponsiveMode mode = ResponsiveMode.adaptiveScale,
  }) =>
      ResponsiveHelper.spacing(this, config, mode: mode);

  double sp(AppSpacing size, {ResponsiveMode mode = ResponsiveMode.adaptiveScale}) =>
      ResponsiveHelper.spacing(
        this,
        AppSpacingConfig(size: size),
        mode: mode,
      );

  EdgeInsets padding(
    AppPaddingConfig config, {
    ResponsiveMode mode = ResponsiveMode.adaptiveScale,
  }) =>
      ResponsiveHelper.padding(this, config, mode: mode);

  EdgeInsetsDirectional paddingDirectional(
    AppPaddingDirectionalConfig config, {
    ResponsiveMode mode = ResponsiveMode.adaptiveScale,
  }) => ResponsiveHelper.paddingDirectional(
    this,
    config,
    mode: mode,
  );

  BorderRadius radius(
    AppRadiusConfig config, {
    ResponsiveMode mode = ResponsiveMode.adaptiveScale,
  }) => ResponsiveHelper.radius(this, config, mode: mode);

  BorderRadiusDirectional radiusDirectional(
    AppRadiusDirectionalConfig config, {
    ResponsiveMode mode = ResponsiveMode.adaptiveScale,
  }) => ResponsiveHelper.radiusDirectional(
    this,
    config,
    mode: mode,
  );

  double font(
    AppFontConfig config, {
    bool respectTextScaler = true,
    ResponsiveMode mode = ResponsiveMode.adaptiveScale,
  }) => ResponsiveHelper.font(
    this,
    config,
    respectTextScaler: respectTextScaler,
    mode: mode,
  );

  TextStyle textStyle(
    AppFontConfig config, {
    FontWeight? weight,
    Color? color,
    ResponsiveMode mode = ResponsiveMode.adaptiveScale,
  }) => ResponsiveHelper.textStyle(
    this,
    config,
    weight: weight,
    color: color,
    mode: mode,
  );

  double size(
    AppSizeConfig config, {
    ResponsiveMode mode = ResponsiveMode.adaptiveScale,
  }) => ResponsiveHelper.size(this, config, mode: mode);

  double iconSize(
    AppIconConfig config, {
    ResponsiveMode mode = ResponsiveMode.adaptiveScale,
  }) =>
      ResponsiveHelper.iconSize(this, config, mode: mode);

  Widget gap(
    AppSpacingConfig config, {
    ResponsiveMode mode = ResponsiveMode.adaptiveScale,
  }) =>
      ResponsiveHelper.gapSpace(this, config, mode: mode);
}

// ═══════════════════════════════════════════════════════════════════
// LIST OF ALL STATIC FUNCTIONS IN ResponsiveHelper CLASS
// ═══════════════════════════════════════════════════════════════════
/*
📋 ResponsiveHelper - Complete List of Static Functions:

1.  fontSimple()           - Simple font method with minimal parameters
2.  font()                 - Advanced font method with full config
3.  textStyle()            - Creates TextStyle with responsive font
4.  spacing()              - Gets responsive spacing value
5.  size()                 - Gets responsive component size
6.  width()                - Gets responsive width (alias for size)
7.  height()               - Gets responsive height (alias for size)
8.  padding()              - Creates EdgeInsets with responsive values
9.  paddingDirectional()   - Creates EdgeInsetsDirectional with RTL support
10. radius()               - Creates BorderRadius with responsive values
11. radiusDirectional()    - Creates BorderRadiusDirectional with RTL support
12. iconSize()             - Gets responsive icon size
13. elevation()            - Gets elevation value (non-scaling)
14. gapSpace()             - Creates Gap widget for spacing

Internal Helper Functions (private):
- _getMobileFixedValue()   - Helper to get mobile baseline value
- _resolveSpacingValue()   - Resolves spacing based on mode
- _resolveRadiusValue()    - Resolves radius based on mode
- _resolveRadiusDirectionalValue() - Resolves directional radius based on mode

Extension Functions (available on BuildContext):
- .spacing()              - Context-aware spacing
- .sp()                   - Shortcut for spacing with AppSpacing
- .padding()              - Context-aware padding
- .paddingDirectional()   - Context-aware directional padding
- .radius()               - Context-aware radius
- .radiusDirectional()    - Context-aware directional radius
- .font()                 - Context-aware font size
- .textStyle()            - Context-aware text style
- .size()                 - Context-aware component size
- .iconSize()             - Context-aware icon size
- .gap()                  - Context-aware gap widget

ResponsiveMode Options:
- fixed          → Uses mobile baseline value only
- scaleOnly      → Scales mobile baseline value by screen width
- adaptiveOnly   → Uses different values per screen type (no scaling)
- adaptiveScale  → Uses different values per screen type AND scales (default)
*//**سؤالك ممتاز جدًا لأنه وصل لمرحلة “هل التصميم system عملي فعلاً ولا صار معقد زيادة” — وهذا الفرق بين كود شغال وكود Production Design System 👌

 */
*/