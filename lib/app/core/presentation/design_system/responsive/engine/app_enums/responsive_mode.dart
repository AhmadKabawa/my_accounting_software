part of '../app_enums.dart';

// ═══════════════════════════════════════════════════════════════════
// RESPONSIVE MODE ENUM
// ═══════════════════════════════════════════════════════════════════

/// Defines how responsive values are calculated
///
/// Each mode provides a different strategy for handling responsive values:
/// - [fixed]: Uses mobile baseline only, no adaptation
/// - [scaleOnly]: Scales mobile baseline by screen width
/// - [adaptiveOnly]: Different values per screen type, no scaling
/// - [adaptiveScale]: Different values AND scales by width (default)
enum ResponsiveMode {
  /// Fixed value - uses mobile baseline only
  fixed,

  /// Scale only - scales mobile baseline by screen width
  scaleOnly,

  /// Adaptive only - different values per screen type, no scaling
  adaptiveOnly,

  /// Adaptive + Scale (default) - different values AND scales by width
  adaptiveScale,
}
