// ─────────────────────────────────────────────────────────────────
// app_button.dart
//
// زر التطبيق الموحّد. كل القيم البصرية (ألوان، أحجام، padding، radius، أيقونة)
// في AppButtonStyle؛ هنا فقط الحالة (pressed) والتفاعل.
// النص عبر AppText بنوع buttonText / buttonTextSmall.
// ─────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_button_style.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';

export 'package:accounting_software/app/core/presentation/widgets/app_button/app_button_style.dart'
    show AppButtonVariant, AppButtonSize;

class AppButton extends StatefulWidget {
  /// key للترجمة
  final AppKey? labelKey;

  /// نص raw بدون ترجمة
  final String? rawLabel;

  /// null = الزر معطّل
  final VoidCallback? onPressed;

  final AppButtonVariant variant;
  final AppButtonSize size;
  final IconData? icon;

  /// يعرض مؤشر تحميل بدل الأيقونة ويمنع الضغط (من دون مظهر التعطيل)
  final bool isLoading;

  /// يملأ عرض الأب (يتطلب أباً بعرض محدود)
  final bool expand;

  /// زر بنص مترجم
  const AppButton(
    AppKey this.labelKey, {
    super.key,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.expand = false,
  }) : rawLabel = null;

  /// زر بنص عادي بدون ترجمة
  const AppButton.raw(
    String this.rawLabel, {
    super.key,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.expand = false,
  }) : labelKey = null;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _pressed = false;

  bool get _tappable => widget.onPressed != null && !widget.isLoading;

  AppButtonState get _state {
    if (widget.onPressed == null) return AppButtonState.disabled;
    return _pressed && _tappable
        ? AppButtonState.pressed
        : AppButtonState.enabled;
  }

  @override
  Widget build(BuildContext context) {
    final styles = AppButtonStyle(context);
    final visual = styles.resolve(widget.variant, widget.size, state: _state);
    final borderColor = visual.borderColor;
    final leading = _buildLeading(styles, visual);

    return Semantics(
      button: true,
      enabled: _tappable,
      child: SizedBox(
        width: widget.expand ? double.infinity : null,
        child: Material(
          color: visual.background,
          shape: RoundedRectangleBorder(
            borderRadius: visual.radius,
            side: borderColor == null
                ? BorderSide.none
                : BorderSide(color: borderColor, width: visual.borderWidth),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: _tappable ? widget.onPressed : null,
            onHighlightChanged: (isPressed) =>
                setState(() => _pressed = isPressed),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: visual.height),
              child: Padding(
                padding: visual.padding,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (leading != null) ...[
                      leading,
                      SizedBox(width: visual.iconGap),
                    ],
                    Flexible(child: _buildLabel(visual)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// The spinner while loading, otherwise the icon (if any).
  Widget? _buildLeading(AppButtonStyle styles, ButtonVisual visual) {
    if (widget.isLoading) {
      return SizedBox.square(
        dimension: visual.iconSize,
        child: CircularProgressIndicator(
          strokeWidth: styles.loadingStrokeWidth,
          color: visual.foreground,
        ),
      );
    }

    final icon = widget.icon;
    if (icon == null) return null;
    return Icon(icon, size: visual.iconSize, color: visual.foreground);
  }

  Widget _buildLabel(ButtonVisual visual) {
    final type = widget.size == AppButtonSize.small
        ? AppTextType.buttonTextSmall
        : AppTextType.buttonText;
    final key = widget.labelKey;

    return key != null
        ? AppText(
            key,
            type: type,
            color: visual.foreground,
            textAlign: TextAlign.center,
            maxLines: 1,
            useEllipsis: true,
          )
        : AppText.raw(
            widget.rawLabel,
            type: type,
            color: visual.foreground,
            textAlign: TextAlign.center,
            maxLines: 1,
            useEllipsis: true,
          );
  }
}
