// ─────────────────────────────────────────────────────────────────
// app_text.dart
//
// إصلاحات v2:
// ✅ textAlign default → TextAlign.start (مش center)
// ✅ style merge — الـ explicit params تـ override الـ style الخارجي
// ✅ AppText.rich للنصوص المختلطة
// ✅ AppText.selectable للنصوص القابلة للنسخ
// ✅ تحسين _resolveText — assert في debug mode
// ─────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text_extension.dart';
import 'package:accounting_software/app/core/foundation/localization/translations/app_key.dart';
import 'app_text_enum.dart';
// import 'app_text_extension.dart';

export 'app_text_enum.dart';

class AppText extends StatelessWidget {
  /// key للترجمة
  final AppKey? textKey;

  /// نص raw بدون ترجمة
  final String? rawText;

  /// نوع النص — يحدد الـ TextStyle من الـ theme
  final AppTextType type;

  /// تخصيصات — تـ override الـ style الخارجي إذا حُددت
  final Color? color;
  final FontWeight? weight;
  final TextAlign? textAlign; // FIX: default أصبح start مش center
  final int? maxLines;
  final TextOverflow? overflow;
  final double? height;
  final double? letterSpacing;
  final bool respectTextScaler;
  final List<Shadow>? shadows;
  final bool useEllipsis;

  /// style خارجي — يُطبق أولاً، ثم تـ override الـ explicit params عليه
  final TextStyle? style;

  // ───────────────────────────────────────────────────────────────
  // CONSTRUCTORS
  // ───────────────────────────────────────────────────────────────

  /// نص مترجم
  const AppText(
    this.textKey, {
    super.key,
    this.type = AppTextType.bodyMedium,
    this.color,
    this.weight,
    this.textAlign, // null = start
    this.maxLines,
    this.overflow,
    this.height,
    this.letterSpacing,
    this.respectTextScaler = true,
    this.shadows,
    this.useEllipsis = false,
    this.style,
  }) : rawText = null;

  /// نص عادي بدون ترجمة
  const AppText.raw(
    this.rawText, {
    super.key,
    this.type = AppTextType.bodyMedium,
    this.color,
    this.weight,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.height,
    this.letterSpacing,
    this.respectTextScaler = true,
    this.shadows,
    this.useEllipsis = false,
    this.style,
  }) : textKey = null;

  /// نص قابل للنسخ (Terms, about pages, etc.)
  static Widget selectable(
    String text, {
    Key? key,
    AppTextType type = AppTextType.bodyMedium,
    Color? color,
    FontWeight? weight,
    TextAlign? textAlign,
    int? maxLines,
    double? height,
    TextStyle? style,
  }) => _AppSelectableText(
    text,
    key: key,
    type: type,
    color: color,
    weight: weight,
    textAlign: textAlign,
    maxLines: maxLines,
    height: height,
    style: style,
  );

  /// نص مختلط (bold + normal في نفس السطر)
  static Widget rich(
    List<AppTextSpan> spans, {
    Key? key,
    AppTextType baseType = AppTextType.bodyMedium,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) => _AppRichText(
    spans,
    key: key,
    baseType: baseType,
    textAlign: textAlign,
    maxLines: maxLines,
    overflow: overflow,
  );

  // ───────────────────────────────────────────────────────────────
  // BUILD
  // ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    assert(
      textKey != null || rawText != null,
      'AppText: يجب تمرير textKey أو rawText',
    );

    final text = _resolveText(context);
    final textStyle = _buildStyle(context);

    return Text(
      text,
      style: textStyle,
      // FIX: default = start مش center
      textAlign: textAlign ?? TextAlign.start,
      maxLines: maxLines,
      overflow: overflow ?? (useEllipsis ? TextOverflow.ellipsis : null),
      softWrap: true,
      textWidthBasis: TextWidthBasis.parent,
      textScaler: respectTextScaler
          ? MediaQuery.textScalerOf(context)
          : const TextScaler.linear(1.0),
    );
  }

  // ───────────────────────────────────────────────────────────────
  // HELPERS
  // ───────────────────────────────────────────────────────────────

  String _resolveText(BuildContext context) {
    final key = textKey;
    if (key != null) return key.tr(context: context);
    return rawText ?? '';
  }

  TextStyle _buildStyle(BuildContext context) {
    final baseStyle = type.resolve(context);

    // FIX: الترتيب الصحيح للـ merge:
    // 1. baseStyle من الـ theme
    // 2. style خارجي (لو موجود)
    // 3. explicit params تـ override كل شيء
    final withExternalStyle = style != null
        ? baseStyle.merge(style)
        : baseStyle;

    return withExternalStyle.copyWith(
      color: color ?? withExternalStyle.color,
      fontWeight: weight ?? withExternalStyle.fontWeight,
      height: height ?? withExternalStyle.height,
      letterSpacing: letterSpacing ?? withExternalStyle.letterSpacing,
      shadows: shadows ?? withExternalStyle.shadows,
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// AppTextSpan — لـ AppText.rich
// ─────────────────────────────────────────────────────────────────

class AppTextSpan {
  final String text;
  final AppTextType? type;
  final Color? color;
  final FontWeight? weight;
  final TextDecoration? decoration;
  final VoidCallback? onTap;

  const AppTextSpan(
    this.text, {
    this.type,
    this.color,
    this.weight,
    this.decoration,
    this.onTap,
  });
}

// ─────────────────────────────────────────────────────────────────
// _AppRichText — internal widget
// ─────────────────────────────────────────────────────────────────

class _AppRichText extends StatelessWidget {
  final List<AppTextSpan> spans;
  final AppTextType baseType;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const _AppRichText(
    this.spans, {
    super.key,
    required this.baseType,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    final baseStyle = baseType.resolve(context);

    return Text.rich(
      TextSpan(
        children: spans.map((span) {
          final spanStyle = (span.type?.resolve(context) ?? baseStyle).copyWith(
            color: span.color,
            fontWeight: span.weight,
            decoration: span.decoration,
          );

          return span.onTap != null
              ? WidgetSpan(
                  child: GestureDetector(
                    onTap: span.onTap,
                    child: Text(span.text, style: spanStyle),
                  ),
                )
              : TextSpan(text: span.text, style: spanStyle);
        }).toList(),
      ),
      textAlign: textAlign ?? TextAlign.start,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// _AppSelectableText — internal widget
// ─────────────────────────────────────────────────────────────────

class _AppSelectableText extends StatelessWidget {
  final String text;
  final AppTextType type;
  final Color? color;
  final FontWeight? weight;
  final TextAlign? textAlign;
  final int? maxLines;
  final double? height;
  final TextStyle? style;

  const _AppSelectableText(
    this.text, {
    super.key,
    required this.type,
    this.color,
    this.weight,
    this.textAlign,
    this.maxLines,
    this.height,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final baseStyle = type.resolve(context);
    final finalStyle = (style != null ? baseStyle.merge(style) : baseStyle)
        .copyWith(color: color, fontWeight: weight, height: height);

    return SelectableText(
      text,
      style: finalStyle,
      textAlign: textAlign ?? TextAlign.start,
      maxLines: maxLines,
    );
  }
}
