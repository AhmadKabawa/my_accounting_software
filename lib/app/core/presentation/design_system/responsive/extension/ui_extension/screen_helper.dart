part of '../ui_extension.dart';

// ═══════════════════════════════════════════════════════════════════
// SCREEN HELPER
// ═══════════════════════════════════════════════════════════════════

class ScreenHelper {
  final BuildContext context;

  const ScreenHelper(this.context);

  /// Get current screen type
  ScreenType get type => ScreenEngine.screenType(context);

  /// Get current orientation
  AppOrientation get orientation => ScreenEngine.orientation(context);

  /// Check if mobile
  bool get isMobile => type == ScreenType.mobile;

  /// Check if tablet
  bool get isTablet => type == ScreenType.tablet;

  /// Check if desktop
  bool get isDesktop => type == ScreenType.desktop;

  /// Check if portrait
  bool get isPortrait => orientation == AppOrientation.portrait;

  /// Check if landscape
  bool get isLandscape => orientation == AppOrientation.landscape;

  /// Screen width
  double width({double rate = 1}) =>
      ScreenEngine.screenWidth(context, rate: rate);

  /// Screen height
  double height({double rate = 1}) =>
      ScreenEngine.screenHeight(context, rate: rate);

  /// Screen size
  Size get size => MediaQuery.sizeOf(context);

  /// Device pixel ratio
  double get pixelRatio => MediaQuery.devicePixelRatioOf(context);

  /// SafeArea padding
  EdgeInsets get safeAreaPadding => ScreenEngine.safeAreaPadding(context);

  /// ViewInsets (keyboard height, etc) — rebuilds only when insets change
  EdgeInsets get viewInsets => MediaQuery.viewInsetsOf(context);
}
