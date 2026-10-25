// ─────────────────────────────────────────────────────────────────
// app_icon_enum.dart
// ─────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

// ── مصدر الأيقونة
enum AppIconSource {
  material,
  custom,
  assetSvg,
  networkSvg,
  assetImage,
  networkImage,
}

// ── أحجام semantic بدلاً من double مباشرة
enum AppIconSize {
  xs,   // 12
  sm,   // 16
  md,   // 24  ← default
  lg,   // 32
  xl,   // 48
  xxl,  // 64
  xxxl, // 96
}

extension AppIconSizeX on AppIconSize {
  double getSize(BuildContext context) => switch (this) {
    AppIconSize.xs   => 12,
    AppIconSize.sm   => 16,
    AppIconSize.md   => 24,
    AppIconSize.lg   => 32,
    AppIconSize.xl   => 48,
    AppIconSize.xxl  => 64,
    AppIconSize.xxxl => 96,
  };
}

// ── شكل الحاوية (للـ AppImage)
enum AppImageShape {
  rectangle,  // صورة عادية
  rounded,    // border radius
  circle,     // دائرة (للـ avatars)
}

// ── أحجام semantic للصور
enum AppImageSize {
  xs,    // 32
  sm,    // 48
  md,    // 80  ← default
  lg,    // 120
  xl,    // 200
  xxl,   // 300
  fill,  // double.infinity
}

extension AppImageSizeX on AppImageSize {
  double getSize(BuildContext context) => switch (this) {
    AppImageSize.xs   => 32,
    AppImageSize.sm   => 48,
    AppImageSize.md   => 80,
    AppImageSize.lg   => 120,
    AppImageSize.xl   => 200,
    AppImageSize.xxl  => 300,
    AppImageSize.fill => double.infinity,
  };
}