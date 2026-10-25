// // ─────────────────────────────────────────────────────────────────
// // app_responsive_configs.dart
// // Config classes — bundle design value + scale parameters for one
// // breakpoint. Pass one config per breakpoint to the adaptive helpers.
// //
// // Depends on: app_enums.dart
// //
// // baseWidth is nullable in ALL configs:
// //   • null  → auto-resolved at render time by ResponsiveHelper
// //             mobile=375  tablet=768  desktop=1280
// //   • value → manual override (use when your Figma frame ≠ default)
// //
// // You almost never need to set baseWidth manually.
// // ─────────────────────────────────────────────────────────────────

// import 'package:accounting_software/app/core/presentation/responsive/engine/app_enums.dart';

// // ══════════════════════════════════════════════════════════════════
// // FONT CONFIG
// // ══════════════════════════════════════════════════════════════════

// class AppFontConfig {
//   final AppFontSize size;
//   final AppBaseWidth? baseWidth;
//   final AppFontSize? min;
//   final AppFontSize? max;
//   final double? height;
//   final double? letterSpacing;

//   const AppFontConfig({
//     required this.size,
//     this.baseWidth,
//     this.min,
//     this.max,
//     this.height,
//     this.letterSpacing,
//   });

//   /// Never scales — always returns exactly [size].
//   const AppFontConfig.fixed(this.size)
//       : baseWidth = AppBaseWidth.phone,
//         min = size,
//         max = size,
//         height = null,
//         letterSpacing = null;
// }

// // ══════════════════════════════════════════════════════════════════
// // SPACING CONFIG
// // ══════════════════════════════════════════════════════════════════

// class AppSpacingConfig {
//   final AppSpacing size;
//   final AppBaseWidth? baseWidth;
//   final AppSpacing? min;
//   final AppSpacing? max;

//   const AppSpacingConfig({
//     required this.size,
//     this.baseWidth,
//     this.min,
//     this.max,
//   });

//   /// Never scales — always returns exactly [size].
//   const AppSpacingConfig.fixed(this.size)
//       : baseWidth = AppBaseWidth.phone,
//         min = size,
//         max = size;
// }

// // ══════════════════════════════════════════════════════════════════
// // SIZE CONFIG (WIDTH & HEIGHT)
// // ══════════════════════════════════════════════════════════════════

// class AppSizeConfig {
//   final AppComponentSize size;
//   final AppBaseWidth? baseWidth;
//   final AppComponentSize? min;
//   final AppComponentSize? max;

//   const AppSizeConfig({
//     required this.size,
//     this.baseWidth,
//     this.min,
//     this.max,
//   });

//   /// Never scales — always returns exactly [size].
//   const AppSizeConfig.fixed(this.size)
//       : baseWidth = AppBaseWidth.phone,
//         min = size,
//         max = size;
// }

// // ══════════════════════════════════════════════════════════════════
// // RADIUS CONFIG
// // ══════════════════════════════════════════════════════════════════
// ///
// /// All enabled corners share the SAME radius value.
// /// For different radii per corner, use BorderRadius.only() directly.

// class AppRadiusConfig {
//   final AppRadius size;
//   final AppBaseWidth? baseWidth;
//   final AppRadius? min;
//   final AppRadius? max;

//   final bool topLeft;
//   final bool topRight;
//   final bool bottomLeft;
//   final bool bottomRight;

//   final bool _isPill;

//   const AppRadiusConfig({
//     required this.size,
//     this.baseWidth,
//     this.min,
//     this.max,
//     this.topLeft = true,
//     this.topRight = true,
//     this.bottomLeft = true,
//     this.bottomRight = true,
//   }) : _isPill = false;

//   /// All corners rounded
//   const AppRadiusConfig.circular({
//     required AppRadius size,
//     AppBaseWidth? baseWidth,
//     AppRadius? min,
//     AppRadius? max,
//   }) : this(
//           size: size,
//           baseWidth: baseWidth,
//           min: min,
//           max: max,
//           topLeft: true,
//           topRight: true,
//           bottomLeft: true,
//           bottomRight: true,
//         );

//   /// Top corners only (BottomSheet style)
//   const AppRadiusConfig.topOnly({
//     required AppRadius size,
//     AppBaseWidth? baseWidth,
//     AppRadius? min,
//     AppRadius? max,
//   }) : this(
//           size: size,
//           baseWidth: baseWidth,
//           min: min,
//           max: max,
//           topLeft: true,
//           topRight: true,
//           bottomLeft: false,
//           bottomRight: false,
//         );

//   /// Bottom corners only
//   const AppRadiusConfig.bottomOnly({
//     required AppRadius size,
//     AppBaseWidth? baseWidth,
//     AppRadius? min,
//     AppRadius? max,
//   }) : this(
//           size: size,
//           baseWidth: baseWidth,
//           min: min,
//           max: max,
//           topLeft: false,
//           topRight: false,
//           bottomLeft: true,
//           bottomRight: true,
//         );

//   /// Left corners only
//   const AppRadiusConfig.leftOnly({
//     required AppRadius size,
//     AppBaseWidth? baseWidth,
//     AppRadius? min,
//     AppRadius? max,
//   }) : this(
//           size: size,
//           baseWidth: baseWidth,
//           min: min,
//           max: max,
//           topLeft: true,
//           topRight: false,
//           bottomLeft: true,
//           bottomRight: false,
//         );

//   /// Right corners only
//   const AppRadiusConfig.rightOnly({
//     required AppRadius size,
//     AppBaseWidth? baseWidth,
//     AppRadius? min,
//     AppRadius? max,
//   }) : this(
//           size: size,
//           baseWidth: baseWidth,
//           min: min,
//           max: max,
//           topLeft: false,
//           topRight: true,
//           bottomLeft: false,
//           bottomRight: true,
//         );

//   /// Custom corner selection (all selected corners get SAME radius)
//   const AppRadiusConfig.only({
//     required AppRadius size,
//     AppBaseWidth? baseWidth,
//     AppRadius? min,
//     AppRadius? max,
//     bool topLeft = false,
//     bool topRight = false,
//     bool bottomLeft = false,
//     bool bottomRight = false,
//   }) : this(
//           size: size,
//           baseWidth: baseWidth,
//           min: min,
//           max: max,
//           topLeft: topLeft,
//           topRight: topRight,
//           bottomLeft: bottomLeft,
//           bottomRight: bottomRight,
//         );

//   /// Fully rounded / pill shape
//   const AppRadiusConfig.pill()
//       : size = AppRadius.full,
//         baseWidth = null,
//         min = null,
//         max = null,
//         topLeft = true,
//         topRight = true,
//         bottomLeft = true,
//         bottomRight = true,
//         _isPill = true;

//   /// Fixed — never scales
//   const AppRadiusConfig.fixed(AppRadius size)
//       : this(
//           size: size,
//           baseWidth: AppBaseWidth.phone,
//           min: size,
//           max: size,
//         );

//   /// Fixed top-only — never scales
//   const AppRadiusConfig.fixedTopOnly(AppRadius size)
//       : this(
//           size: size,
//           baseWidth: AppBaseWidth.phone,
//           min: size,
//           max: size,
//           topLeft: true,
//           topRight: true,
//           bottomLeft: false,
//           bottomRight: false,
//         );

//   bool get isPill => _isPill;

//   bool get isCircular =>
//       topLeft && topRight && bottomLeft && bottomRight && !_isPill;
// }

// // ══════════════════════════════════════════════════════════════════
// // RADIUS DIRECTIONAL CONFIG
// // ══════════════════════════════════════════════════════════════════

// class AppRadiusDirectionalConfig {
//   final AppRadius size;
//   final AppBaseWidth? baseWidth;
//   final AppRadius? min;
//   final AppRadius? max;

//   final bool topStart;
//   final bool topEnd;
//   final bool bottomStart;
//   final bool bottomEnd;

//   final bool _isPill;

//   const AppRadiusDirectionalConfig({
//     required this.size,
//     this.baseWidth,
//     this.min,
//     this.max,
//     this.topStart = true,
//     this.topEnd = true,
//     this.bottomStart = true,
//     this.bottomEnd = true,
//   }) : _isPill = false;

//   const AppRadiusDirectionalConfig.circular({
//     required AppRadius size,
//     AppBaseWidth? baseWidth,
//     AppRadius? min,
//     AppRadius? max,
//   }) : this(
//           size: size,
//           baseWidth: baseWidth,
//           min: min,
//           max: max,
//           topStart: true,
//           topEnd: true,
//           bottomStart: true,
//           bottomEnd: true,
//         );

//   const AppRadiusDirectionalConfig.topOnly({
//     required AppRadius size,
//     AppBaseWidth? baseWidth,
//     AppRadius? min,
//     AppRadius? max,
//   }) : this(
//           size: size,
//           baseWidth: baseWidth,
//           min: min,
//           max: max,
//           topStart: true,
//           topEnd: true,
//           bottomStart: false,
//           bottomEnd: false,
//         );

//   const AppRadiusDirectionalConfig.bottomOnly({
//     required AppRadius size,
//     AppBaseWidth? baseWidth,
//     AppRadius? min,
//     AppRadius? max,
//   }) : this(
//           size: size,
//           baseWidth: baseWidth,
//           min: min,
//           max: max,
//           topStart: false,
//           topEnd: false,
//           bottomStart: true,
//           bottomEnd: true,
//         );

//   const AppRadiusDirectionalConfig.startOnly({
//     required AppRadius size,
//     AppBaseWidth? baseWidth,
//     AppRadius? min,
//     AppRadius? max,
//   }) : this(
//           size: size,
//           baseWidth: baseWidth,
//           min: min,
//           max: max,
//           topStart: true,
//           topEnd: false,
//           bottomStart: true,
//           bottomEnd: false,
//         );

//   const AppRadiusDirectionalConfig.endOnly({
//     required AppRadius size,
//     AppBaseWidth? baseWidth,
//     AppRadius? min,
//     AppRadius? max,
//   }) : this(
//           size: size,
//           baseWidth: baseWidth,
//           min: min,
//           max: max,
//           topStart: false,
//           topEnd: true,
//           bottomStart: false,
//           bottomEnd: true,
//         );

//   const AppRadiusDirectionalConfig.only({
//     required AppRadius size,
//     AppBaseWidth? baseWidth,
//     AppRadius? min,
//     AppRadius? max,
//     bool topStart = false,
//     bool topEnd = false,
//     bool bottomStart = false,
//     bool bottomEnd = false,
//   }) : this(
//           size: size,
//           baseWidth: baseWidth,
//           min: min,
//           max: max,
//           topStart: topStart,
//           topEnd: topEnd,
//           bottomStart: bottomStart,
//           bottomEnd: bottomEnd,
//         );

//   const AppRadiusDirectionalConfig.pill()
//       : size = AppRadius.full,
//         baseWidth = null,
//         min = null,
//         max = null,
//         topStart = true,
//         topEnd = true,
//         bottomStart = true,
//         bottomEnd = true,
//         _isPill = true;

//   const AppRadiusDirectionalConfig.fixed(AppRadius size)
//       : this(
//           size: size,
//           baseWidth: AppBaseWidth.phone,
//           min: size,
//           max: size,
//         );

//   const AppRadiusDirectionalConfig.fixedTopOnly(AppRadius size)
//       : this(
//           size: size,
//           baseWidth: AppBaseWidth.phone,
//           min: size,
//           max: size,
//           topStart: true,
//           topEnd: true,
//           bottomStart: false,
//           bottomEnd: false,
//         );

//   bool get isPill => _isPill;

//   bool get isCircular =>
//       topStart && topEnd && bottomStart && bottomEnd && !_isPill;
// }

// // ══════════════════════════════════════════════════════════════════
// // ICON CONFIG
// // ══════════════════════════════════════════════════════════════════

// class AppIconConfig {
//   final AppIconSize size;
//   final AppBaseWidth? baseWidth;
//   final AppIconSize? min;
//   final AppIconSize? max;

//   const AppIconConfig({
//     required this.size,
//     this.baseWidth,
//     this.min,
//     this.max,
//   });

//   /// Never scales — always returns exactly [size].
//   const AppIconConfig.fixed(this.size)
//       : baseWidth = AppBaseWidth.phone,
//         min = size,
//         max = size;
// }

// // ══════════════════════════════════════════════════════════════════
// // ELEVATION CONFIG
// // ══════════════════════════════════════════════════════════════════

// class AppElevationConfig {
//   final AppElevation size;

//   const AppElevationConfig({required this.size});

//   /// Never scales — always returns exactly [size].
//   const AppElevationConfig.fixed(this.size);
// }

// // ══════════════════════════════════════════════════════════════════
// // PADDING CONFIG
// // ══════════════════════════════════════════════════════════════════
// ///
// /// Flexible padding configuration with per-edge control.
// ///
// /// Priority for each edge:
// ///   1. explicit edge (top, bottom, left, right)
// ///   2. axis shorthand (horizontal, vertical)
// ///   3. all
// ///   4. AppSpacing.none
// ///
// /// **min/max handling:**
// /// When edge values differ → must specify min (smallest) and max (largest).
// /// When all values are equal → min/max can be omitted.
// ///
// /// ```dart
// /// // ✅ Equal values
// /// AppPaddingConfig.symmetric(h: AppSpacing.md, v: AppSpacing.md)
// ///
// /// // ✅ Different values — specify min/max!
// /// AppPaddingConfig.only(
// ///   left: AppSpacing.lg,
// ///   right: AppSpacing.lg,
// ///   top: AppSpacing.md,
// ///   bottom: AppSpacing.md,
// ///   min: AppSpacing.md,   // smallest
// ///   max: AppSpacing.lg,   // largest
// /// )
// /// ```

// class AppPaddingConfig {
//   final AppSpacing? all;
//   final AppSpacing? horizontal;
//   final AppSpacing? vertical;
//   final AppSpacing? top;
//   final AppSpacing? bottom;
//   final AppSpacing? left;
//   final AppSpacing? right;
//   final AppBaseWidth? baseWidth;
//   final AppSpacing? min;
//   final AppSpacing? max;

//   const AppPaddingConfig({
//     this.all,
//     this.horizontal,
//     this.vertical,
//     this.top,
//     this.bottom,
//     this.left,
//     this.right,
//     this.baseWidth,
//     this.min,
//     this.max,
//   });

//   /// Symmetric padding: left=right, top=bottom.
//   /// ⚠️ If h ≠ v, provide min/max!
//   const AppPaddingConfig.symmetric({
//     AppSpacing h = AppSpacing.none,
//     AppSpacing v = AppSpacing.none,
//     // FIX: was `baseWidth ?? AppBaseWidth.phone` — must pass null through
//     // so ResponsiveHelper can auto-select the correct base for each screen type.
//     AppBaseWidth? baseWidth,
//     AppSpacing? min,
//     AppSpacing? max,
//   })  : all = null,
//         horizontal = h,
//         vertical = v,
//         top = null,
//         bottom = null,
//         left = null,
//         right = null,
//         this.baseWidth = baseWidth,
//         this.min = min,
//         this.max = max;

//   /// All edges — same value, never scales
//   const AppPaddingConfig.allFixed(AppSpacing value)
//       : all = value,
//         horizontal = null,
//         vertical = null,
//         top = null,
//         bottom = null,
//         left = null,
//         right = null,
//         baseWidth = AppBaseWidth.phone,
//         min = value,
//         max = value;

//   /// Per-edge control — unspecified edges default to AppSpacing.none
//   const AppPaddingConfig.only({
//     AppSpacing top = AppSpacing.none,
//     AppSpacing bottom = AppSpacing.none,
//     AppSpacing left = AppSpacing.none,
//     AppSpacing right = AppSpacing.none,
//     AppBaseWidth? baseWidth,
//     AppSpacing? min,
//     AppSpacing? max,
//   })  : all = null,
//         horizontal = null,
//         vertical = null,
//         this.top = top,
//         this.bottom = bottom,
//         this.left = left,
//         this.right = right,
//         this.baseWidth = baseWidth,
//         this.min = min,
//         this.max = max;

//   /// All edges — same value, scalable
//   const AppPaddingConfig.all({
//     required AppSpacing value,
//     AppBaseWidth? baseWidth,
//     AppSpacing? min,
//     AppSpacing? max,
//   })  : all = value,
//         horizontal = null,
//         vertical = null,
//         top = null,
//         bottom = null,
//         left = null,
//         right = null,
//         this.baseWidth = baseWidth,
//         this.min = min,
//         this.max = max;

//   AppSpacing get resolvedLeft => left ?? horizontal ?? all ?? AppSpacing.none;
//   AppSpacing get resolvedRight => right ?? horizontal ?? all ?? AppSpacing.none;
//   AppSpacing get resolvedTop => top ?? vertical ?? all ?? AppSpacing.none;
//   AppSpacing get resolvedBottom => bottom ?? vertical ?? all ?? AppSpacing.none;
// }

// // ══════════════════════════════════════════════════════════════════
// // PADDING DIRECTIONAL CONFIG
// // ══════════════════════════════════════════════════════════════════

// class AppPaddingDirectionalConfig {
//   final AppSpacing? all;
//   final AppSpacing? horizontal;
//   final AppSpacing? vertical;
//   final AppSpacing? start;
//   final AppSpacing? end;
//   final AppSpacing? top;
//   final AppSpacing? bottom;
//   final AppBaseWidth? baseWidth;
//   final AppSpacing? min;
//   final AppSpacing? max;

//   const AppPaddingDirectionalConfig({
//     this.all,
//     this.horizontal,
//     this.vertical,
//     this.start,
//     this.end,
//     this.top,
//     this.bottom,
//     this.baseWidth,
//     this.min,
//     this.max,
//   });

//   const AppPaddingDirectionalConfig.all({
//     required AppSpacing value,
//     AppBaseWidth? baseWidth,
//     AppSpacing? min,
//     AppSpacing? max,
//   })  : all = value,
//         horizontal = null,
//         vertical = null,
//         start = null,
//         end = null,
//         top = null,
//         bottom = null,
//         this.baseWidth = baseWidth,
//         this.min = min,
//         this.max = max;

//   const AppPaddingDirectionalConfig.allFixed(AppSpacing value)
//       : all = value,
//         horizontal = null,
//         vertical = null,
//         start = null,
//         end = null,
//         top = null,
//         bottom = null,
//         baseWidth = AppBaseWidth.phone,
//         min = value,
//         max = value;

//   const AppPaddingDirectionalConfig.symmetric({
//     AppSpacing h = AppSpacing.none,
//     AppSpacing v = AppSpacing.none,
//     AppBaseWidth? baseWidth,
//     AppSpacing? min,
//     AppSpacing? max,
//   })  : all = null,
//         horizontal = h,
//         vertical = v,
//         start = null,
//         end = null,
//         top = null,
//         bottom = null,
//         this.baseWidth = baseWidth,
//         this.min = min,
//         this.max = max;

//   const AppPaddingDirectionalConfig.only({
//     AppSpacing start = AppSpacing.none,
//     AppSpacing end = AppSpacing.none,
//     AppSpacing top = AppSpacing.none,
//     AppSpacing bottom = AppSpacing.none,
//     AppBaseWidth? baseWidth,
//     AppSpacing? min,
//     AppSpacing? max,
//   })  : all = null,
//         horizontal = null,
//         vertical = null,
//         this.start = start,
//         this.end = end,
//         this.top = top,
//         this.bottom = bottom,
//         this.baseWidth = baseWidth,
//         this.min = min,
//         this.max = max;

//   /// Fixed per-edge — never scales.
//   ///
//   /// FIX: min/max now correctly use the smallest/largest of the four values
//   /// instead of always referencing [start].
//   const AppPaddingDirectionalConfig.fixed({
//     required AppSpacing start,
//     required AppSpacing end,
//     required AppSpacing top,
//     required AppSpacing bottom,
//     // Caller must supply correct min/max when values differ.
//     // Defaults to start for equal-value usage.
//     AppSpacing? min,
//     AppSpacing? max,
//   })  : all = null,
//         horizontal = null,
//         vertical = null,
//         this.start = start,
//         this.end = end,
//         this.top = top,
//         this.bottom = bottom,
//         baseWidth = AppBaseWidth.phone,
//         this.min = min ?? start,
//         this.max = max ?? start;

//   AppSpacing get resolvedStart => start ?? horizontal ?? all ?? AppSpacing.none;
//   AppSpacing get resolvedEnd => end ?? horizontal ?? all ?? AppSpacing.none;
//   AppSpacing get resolvedTop => top ?? vertical ?? all ?? AppSpacing.none;
//   AppSpacing get resolvedBottom => bottom ?? vertical ?? all ?? AppSpacing.none;
// }
