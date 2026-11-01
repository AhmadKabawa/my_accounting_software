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
  // DEFAULT BASE WIDTH — قاعدة واحدة ثابتة لكل الشاشات
  //
  // الـ scale يضرب قيمة الـ mobile، لذلك قاعدته عرض تصميم الـ mobile دائماً.
  // اختيار قاعدة مختلفة لكل نوع شاشة (375/768/1280) كان يسبب قفزة في القيمة
  // عند الانتقال بين الأنواع (مثلاً عند عرض 600).
  // ══════════════════════════════════════════════════════════════

  static const AppBaseWidth defaultBaseWidth = AppBaseWidth.phone;

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

    final base = (configBaseWidth ?? defaultBaseWidth).value;
    final ratio = ScreenEngine.scaleWidth(context) / base;
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
  // ADAPTIVE SCALE — تدرّج متصل بين قيم mobile / tablet / desktop
  //
  // القيمة تُحسب مرة واحدة فقط: نقاط الارتكاز phone(375) → tablet(768) →
  // desktop(1280)، والقيمة تُستكمل خطياً بينها (بدون قفزات عند الحدود).
  // أصغر من 375 تتناسب القيمة مع العرض، وأكبر من 1280 تثبت قيمة desktop.
  // ══════════════════════════════════════════════════════════════

  static double interpolate(BuildContext context, ResponsiveToken token) {
    // AppComponentSize.full وأشباهه
    if (token.mobile.isInfinite) return token.mobile;

    final w = ScreenEngine.scaleWidth(context);
    final phone = AppBaseWidth.phone.value;
    final tablet = AppBaseWidth.tablet.value;
    final desktop = AppBaseWidth.desktop.value;

    if (w <= phone) return token.mobile * (w / phone);
    if (w >= desktop) return token.desktop;
    if (w <= tablet) {
      return _lerp(token.mobile, token.tablet, (w - phone) / (tablet - phone));
    }
    return _lerp(
      token.tablet,
      token.desktop,
      (w - tablet) / (desktop - tablet),
    );
  }

  static double _lerp(double a, double b, double t) => a + (b - a) * t;

  /// [interpolate] for [size], clamped between [min] and [max] — which are
  /// interpolated the same way, so all three live on the same curve.
  static double adaptiveScale(
    BuildContext context, {
    required ResponsiveToken size,
    required ResponsiveToken min,
    required ResponsiveToken max,
  }) {
    final value = interpolate(context, size);
    if (value.isInfinite) return value;

    final a = interpolate(context, min);
    final b = interpolate(context, max);
    return value.clamp(a < b ? a : b, a < b ? b : a);
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

    return applyTextScaler(
      context,
      scaled,
      respectTextScaler: respectTextScaler,
    );
  }

  /// يطبّق إعداد حجم الخط في الجهاز على [value] (انظر scaleFont).
  static double applyTextScaler(
    BuildContext context,
    double value, {
    bool respectTextScaler = true,
  }) {
    if (!respectTextScaler) return value;

    // يحترم المستخدم لكن يمنع التضخم الزائد (max 1.3×)
    final textScaler = MediaQuery.maybeTextScalerOf(context);
    if (textScaler == null) return value;
    return textScaler.clamp(maxScaleFactor: 1.3).scale(value);
  }
}
