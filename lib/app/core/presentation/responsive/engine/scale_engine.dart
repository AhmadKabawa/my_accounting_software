// ─────────────────────────────────────────────────────────────────
// scale_engine.dart
// Layer 0 — معادلة الـ scale + TextScaler للـ accessibility
// لا يُستخدم مباشرة من الـ UI
// ─────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/responsive/engine/app_enums.dart';
import 'screen_engine.dart';

abstract final class ScaleEngine {
  // ══════════════════════════════════════════════════════════════
  // DEFAULT BASE WIDTH — يختار تلقائياً حسب نوع الشاشة
  // ══════════════════════════════════════════════════════════════

  static AppBaseWidth defaultBaseWidth(BuildContext context) =>
      switch (ScreenEngine.screenType(context)) {
        ScreenType.mobile => AppBaseWidth.phone,
        ScreenType.tablet => AppBaseWidth.tablet,
        ScreenType.desktop => AppBaseWidth.desktop,
      };

  // ══════════════════════════════════════════════════════════════
  // CORE SCALE — للأبعاد (spacing, radius, icon, size)
  // لا يشمل TextScaler — الأبعاد لا تتأثر بـ accessibility font
  // ══════════════════════════════════════════════════════════════

  static double scale(
    BuildContext context, {
    required double designValue,
    AppBaseWidth? configBaseWidth,
    required double minValue,
    required double maxValue,
  }) {
    // إذا كانت القيمة infinity (مثل AppComponentSize.full) نُرجعها مباشرة
    if (designValue == double.infinity) return double.infinity;

    final base = (configBaseWidth ?? defaultBaseWidth(context)).value;
    final ratio = ScreenEngine.screenWidth(context) / base;
    if (minValue > maxValue) {
      final temp = minValue;
      minValue = maxValue;
      maxValue = temp;
    }
    final raw = designValue * ratio;

    // 🧯 2. حماية NaN / Infinity
    if (raw.isNaN || raw.isInfinite) {
      return minValue;
    }
    assert(minValue <= maxValue, "min must be <= max");
    return raw.clamp(minValue, maxValue);
  }

  // ══════════════════════════════════════════════════════════════
  // FONT SCALE — يحترم إعداد حجم الخط في الجهاز (Accessibility)
  //
  // respectTextScaler: true  → يحترم إعداد الجهاز (الافتراضي)
  //                   false  → للعناصر التي يجب ألا تكبر
  //                            مثل: badge أرقام، أيقونات نصية
  // ══════════════════════════════════════════════════════════════

  static double scaleFont(
    BuildContext context, {
    required double designValue,
    AppBaseWidth? configBaseWidth,
    required double minValue,
    required double maxValue,
    bool respectTextScaler = true,
  }) {
    final scaled = scale(
      context,
      designValue: designValue,
      configBaseWidth: configBaseWidth,
      minValue: minValue,
      maxValue: maxValue,
    );

    if (!respectTextScaler) return scaled;

    // يحترم المستخدم لكن يمنع التضخم الزائد (max 1.3×)
    final textScaler = MediaQuery.maybeTextScalerOf(context);
    if (textScaler == null) return scaled;
    return textScaler.clamp(maxScaleFactor: 1.3).scale(scaled);
  }
}
