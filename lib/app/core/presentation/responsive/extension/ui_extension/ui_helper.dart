part of '../ui_extension.dart';

// ═══════════════════════════════════════════════════════════════════
// UI HELPER - التجميعة الرئيسية
// ═══════════════════════════════════════════════════════════════════

class UIHelper {
  final BuildContext context;

  const UIHelper(this.context);

  /// نظام الـ Padding والـ Margin والـ Spacing
  PaddingHelper get padding => PaddingHelper(context);

  /// نظام الأحجام (width, height, sizes)
  SizeHelper get size => SizeHelper(context);

  /// نظام Typography
  TypographyHelper get text => TypographyHelper(context);

  /// نظام Spacing البسيط
  SpacingHelper get spacing => SpacingHelper(context);

  /// نظام BorderRadius
  RadiusHelper get radius => RadiusHelper(context);

  /// نظام الرموز والأيقونات
  IconHelper get icon => IconHelper(context);

  /// نظام الـ Elevation والظلال
  ElevationHelper get shadow => ElevationHelper(context);

  /// نظام Grid والـ responsive layout
  GridHelper get grid => GridHelper(context);

  /// معلومات الشاشة والـ Orientation
  ScreenHelper get screen => ScreenHelper(context);

  /// نظام Themes والألوان (extension اختياري)
  // ThemeHelper get theme => ThemeHelper(context);
  ThemeHelper get theme => ThemeHelper(context);
  // LocaleHelper get locale => LocaleHelper(context);
  ///
  DirectionHelper get dir => DirectionHelper(context);
}
