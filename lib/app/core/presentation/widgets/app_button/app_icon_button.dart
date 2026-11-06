// ─────────────────────────────────────────────────────────────────
// app_icon_button.dart
//
// زر أيقونة ضمن نظام الأزرار: نفس الـ variants والتوكنز (AppButtonStyle)،
// منطقة لمس لا تقل عن 48، و tooltip مترجم مطلوب (Semantics).
// ─────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_button_style.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';

class AppIconButton extends StatefulWidget {
  const AppIconButton(
    this.icon, {
    super.key,
    required this.tooltipKey,
    required this.onPressed,
    this.variant = AppButtonVariant.text,
    this.size = AppButtonSize.medium,
    this.color,
  });

  /// Take it from `AppIcons`.
  final AppIconData icon;

  /// Required: the accessible name and the tooltip.
  final AppKey tooltipKey;

  /// null = disabled.
  final VoidCallback? onPressed;

  final AppButtonVariant variant;
  final AppButtonSize size;

  /// Overrides the icon color only.
  final Color? color;

  @override
  State<AppIconButton> createState() => _AppIconButtonState();
}

class _AppIconButtonState extends State<AppIconButton> {
  bool _pressed = false;

  AppButtonState get _state {
    if (widget.onPressed == null) return AppButtonState.disabled;
    return _pressed ? AppButtonState.pressed : AppButtonState.enabled;
  }

  @override
  Widget build(BuildContext context) {
    final styles = AppButtonStyle(context);
    final visual = styles.resolve(widget.variant, widget.size, state: _state);
    final borderColor = visual.borderColor;
    final label = widget.tooltipKey.tr(context: context);

    return Tooltip(
      message: label,
      child: Semantics(
        button: true,
        enabled: widget.onPressed != null,
        label: label,
        excludeSemantics: true,
        child: SizedBox.square(
          dimension: styles.touchTarget,
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
              onTap: widget.onPressed,
              onHighlightChanged: (isPressed) =>
                  setState(() => _pressed = isPressed),
              child: Center(
                child: AppIcon.fixed(
                  widget.icon,
                  pixelSize: visual.iconSize,
                  color: widget.color ?? visual.foreground,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
