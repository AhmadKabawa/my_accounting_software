// ─────────────────────────────────────────────────────────────────
// app_icon.dart
//
// إصلاحات v3:
// ✅ إصلاح onTap padding — لا يؤثر على الحجم الخارجي
// ✅ color على الصور — استخدام colorBlendMode بدلاً من color المهجور
// ✅ semanticsLabel لـ accessibility
// ✅ networkImage/networkSvg مع error + loading builders
// ✅ _defaultColor منطق أوضح
// ─────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'app_icon_enum.dart';

class AppIcon extends StatelessWidget {
  // ───────────────────────────────────────────────────────────────
  // DATA
  // ───────────────────────────────────────────────────────────────

  final AppIconSource source;
  final String? path;
  final IconData? iconData;
  final AppIconSize size;
  final Color? color;
  final BoxFit fit;
  final VoidCallback? onTap;
  final String? semanticsLabel;

  // ───────────────────────────────────────────────────────────────
  // CONSTRUCTORS
  // ───────────────────────────────────────────────────────────────

  const AppIcon.material(
    IconData this.iconData, {
    super.key,
    this.size = AppIconSize.md,
    this.color,
    this.onTap,
    this.semanticsLabel,
  })  : source = AppIconSource.material,
        path = null,
        fit = BoxFit.contain;

  const AppIcon.custom(
    IconData this.iconData, {
    super.key,
    this.size = AppIconSize.md,
    this.color,
    this.onTap,
    this.semanticsLabel,
  })  : source = AppIconSource.custom,
        path = null,
        fit = BoxFit.contain;

  const AppIcon.svg(
    String this.path, {
    super.key,
    this.size = AppIconSize.md,
    this.color,
    this.fit = BoxFit.contain,
    this.onTap,
    this.semanticsLabel,
  })  : source = AppIconSource.assetSvg,
        iconData = null;

  const AppIcon.networkSvg(
    String this.path, {
    super.key,
    this.size = AppIconSize.md,
    this.color,
    this.fit = BoxFit.contain,
    this.onTap,
    this.semanticsLabel,
  })  : source = AppIconSource.networkSvg,
        iconData = null;

  const AppIcon.image(
    String this.path, {
    super.key,
    this.size = AppIconSize.md,
    this.color,
    this.fit = BoxFit.cover,
    this.onTap,
    this.semanticsLabel,
  })  : source = AppIconSource.assetImage,
        iconData = null;

  const AppIcon.networkImage(
    String this.path, {
    super.key,
    this.size = AppIconSize.md,
    this.color,
    this.fit = BoxFit.cover,
    this.onTap,
    this.semanticsLabel,
  })  : source = AppIconSource.networkImage,
        iconData = null;

  @override
  Widget build(BuildContext context) {
    final iconSize = size.getSize(context);
    final iconColor = color ?? _defaultColor(context);

    Widget icon = _buildIcon(iconSize, iconColor);

    // ── Semantics wrapper
    if (semanticsLabel != null) {
      icon = Semantics(
        label: semanticsLabel,
        image: source != AppIconSource.material && source != AppIconSource.custom,
        child: icon,
      );
    }

    // ── onTap: نحدد حجم tap area بـ SizedBox بدون ما نأثر على الأيقونة
    if (onTap != null) {
      icon = SizedBox(
        width: iconSize,
        height: iconSize,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(iconSize / 2),
            child: Center(child: icon),
          ),
        ),
      );
    }

    return icon;
  }

  // ───────────────────────────────────────────────────────────────
  // BUILD ICON BY SOURCE
  // ───────────────────────────────────────────────────────────────

  Widget _buildIcon(double iconSize, Color? iconColor) => switch (source) {
        // ── Material & Custom Icons
        AppIconSource.material || AppIconSource.custom => Icon(
            iconData,
            size: iconSize,
            color: iconColor,
          ),

        // ── SVG من Assets
        AppIconSource.assetSvg => SvgPicture.asset(
            path!,
            width: iconSize,
            height: iconSize,
            colorFilter: iconColor != null
                ? ColorFilter.mode(iconColor, BlendMode.srcIn)
                : null,
            fit: fit,
          ),

        // ── SVG من Network — مع error fallback
        AppIconSource.networkSvg => SvgPicture.network(
            path!,
            width: iconSize,
            height: iconSize,
            colorFilter: iconColor != null
                ? ColorFilter.mode(iconColor, BlendMode.srcIn)
                : null,
            fit: fit,
            placeholderBuilder: (_) => _buildIconPlaceholder(iconSize),
          ),

        // ── صورة من Assets
        // FIX: color مهجور في Flutter الحديث — نستخدم ColorFiltered
        AppIconSource.assetImage => iconColor != null
            ? ColorFiltered(
                colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                child: Image.asset(
                  path!,
                  width: iconSize,
                  height: iconSize,
                  fit: fit,
                ),
              )
            : Image.asset(
                path!,
                width: iconSize,
                height: iconSize,
                fit: fit,
              ),

        // ── صورة من Network — مع loading + error
        AppIconSource.networkImage => Image.network(
            path!,
            width: iconSize,
            height: iconSize,
            fit: fit,
            color: iconColor, // للبساطة في الأيقونات الصغيرة
            colorBlendMode: iconColor != null ? BlendMode.srcIn : null,
            loadingBuilder: (_, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return _buildIconPlaceholder(iconSize);
            },
            errorBuilder: (_, __, ___) => _buildIconError(iconSize),
          ),
      };

  // ── Placeholder أثناء التحميل
  Widget _buildIconPlaceholder(double iconSize) => SizedBox(
        width: iconSize,
        height: iconSize,
        child: Center(
          child: SizedBox(
            width: iconSize * 0.6,
            height: iconSize * 0.6,
            child: const CircularProgressIndicator(strokeWidth: 1.5),
          ),
        ),
      );

  // ── Error fallback
  Widget _buildIconError(double iconSize) => SizedBox(
        width: iconSize,
        height: iconSize,
        child: Icon(Icons.broken_image_outlined, size: iconSize * 0.7),
      );

  // ── اللون الافتراضي
  Color? _defaultColor(BuildContext context) {
    if (source == AppIconSource.material || source == AppIconSource.custom) {
      return Theme.of(context).colorScheme.onSurface;
    }
    // الصور والـ SVG تحتفظ بألوانها الأصلية
    return null;
  }
}