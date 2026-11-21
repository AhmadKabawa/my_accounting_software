import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text_field/app_text_field_style.dart';

/// The app's text input: a labelled `TextFormField` whose look comes from
/// `AppTextFieldStyle` (tokens), with a translated label and `AppIconData`
/// icons. Validation is supplied by the caller (`AppValidator`).
///
/// A password toggle is an `AppIconButton` passed as [suffix].
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.labelKey,
    this.validator,
    this.hintKey,
    this.prefixIcon,
    this.suffix,
    this.keyboardType,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.maxLines = 1,
    this.autofillHints,
    this.textInputAction = TextInputAction.next,
    this.onChanged,
    this.onTap,
    this.focusNode,
    this.onSubmitted,
    this.density,
    this.inputFormatters,
    this.textDirection,
    this.textCapitalization = TextCapitalization.none,
  });

  final TextEditingController controller;
  final AppKey labelKey;
  final AppKey? hintKey;
  final String? Function(String?)? validator;
  final AppIconData? prefixIcon;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool enabled;

  /// A read-only field keeps the normal (enabled) look, unlike [enabled]
  /// false, which renders it greyed out as if unavailable.
  final bool readOnly;
  final bool autofocus;
  final int? maxLines;
  final Iterable<String>? autofillHints;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final FocusNode? focusNode;
  final VoidCallback? onSubmitted;

  /// Optional per-field override; null inherits AppDensityScope.
  final AppDensity? density;

  /// Restricts what can be typed (for example hex digits only).
  final List<TextInputFormatter>? inputFormatters;

  /// Forces a direction for values that are always left-to-right (codes, hex).
  final TextDirection? textDirection;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    final style = AppTextFieldStyle(context, density: density);
    final icon = prefixIcon;

    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      obscureText: obscureText,
      enabled: enabled,
      readOnly: readOnly,
      onTap: onTap,
      autofocus: autofocus,
      // A field that hides its text must be single line.
      maxLines: obscureText ? 1 : maxLines,
      autofillHints: autofillHints,
      textInputAction: textInputAction,
      validator: validator,
      inputFormatters: inputFormatters,
      textDirection: textDirection,
      textCapitalization: textCapitalization,
      onChanged: onChanged,
      style: style.textStyle,
      onFieldSubmitted: onSubmitted == null ? null : (_) => onSubmitted!(),
      // `tr(context:)` depends on Localizations, so the label follows the
      // current language without any extra listener.
      decoration: style.decoration(
        label: labelKey.tr(context: context),
        hint: hintKey?.tr(context: context),
        prefix: icon == null ? null : AppIcon(icon, color: style.iconColor),
        suffix: suffix,
      ),
    );
  }
}
