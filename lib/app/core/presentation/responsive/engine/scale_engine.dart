// ─────────────────────────────────────────────────────────────────
// scale_engine.dart
// Layer 0 — معادلة الـ scale (الأبعاد وأحجام الخط)
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
  // FONT SCALE — حجم الخط حسب الشاشة فقط
  //
  // لا يضرب TextScaler هنا: ويدجت Text يطبّقه بنفسه، وحدّه الأقصى
  // يُضبط مرة واحدة في MaterialApp.builder (انظر app.dart).
  // لتعطيل تكبير الـ accessibility لنص معيّن استخدم
  // textScaler: TextScaler.noScaling على الـ Text نفسه.
  // ══════════════════════════════════════════════════════════════

  static double scaleFont(
    BuildContext context, {
    required double designValue,
    AppBaseWidth? configBaseWidth,
    required double minValue,
    required double maxValue,
  }) => scale(
    context,
    designValue: designValue,
    configBaseWidth: configBaseWidth,
    minValue: minValue,
    maxValue: maxValue,
  );
}
