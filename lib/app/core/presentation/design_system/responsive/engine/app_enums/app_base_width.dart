part of '../app_enums.dart';

// ═══════════════════════════════════════════════════════════════════
// BASE WIDTH (Figma Frame Reference)
// ═══════════════════════════════════════════════════════════════════

/// Reference screen widths for design tokens (Figma frame sizes)
///
/// These values represent common device widths used as design references:
/// - Small phones: 320px (iPhone SE, Galaxy Fold folded)
/// - Standard phones: 375px (iPhone 12/13/14)
/// - Pro phones: 390px (iPhone 15 Pro)
/// - Large phones: 430px (iPhone 15 Pro Max)
/// - Wide phones/foldables: 600px (Galaxy Fold unfolded)
/// - Tablets: 768px (iPad Mini)
/// - Large tablets: 1024px (iPad Pro 11")
/// - Desktops: 1280px (HD ready)
/// - Wide desktops: 1440px (Full HD+)
enum AppBaseWidth {
  /// Small phones (iPhone SE, Galaxy Fold folded) - 320px
  small(320),

  /// Standard phones (iPhone 12/13/14) - 375px
  phone(375),

  /// Pro phones (iPhone 15 Pro) - 390px
  phonePro(390),

  /// Large phones (iPhone 15 Pro Max) - 430px
  phoneLarge(430),

  /// Wide phones / foldables (Galaxy Fold unfolded) - 600px
  phoneWide(600),

  /// Tablets (iPad Mini) - 768px
  tablet(768),

  /// Large tablets (iPad Pro 11") - 1024px
  tabletLarge(1024),

  /// Desktop (HD ready) - 1280px
  desktop(1280),

  /// Wide desktop (Full HD+) - 1440px
  desktopWide(1440);

  const AppBaseWidth(this.value);

  /// The width value in pixels
  final double value;
}
