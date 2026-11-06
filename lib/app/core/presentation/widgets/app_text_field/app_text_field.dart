import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
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
    this.maxLines = 1,
    this.autofillHints,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
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
  final int? maxLines;
  final Iterable<String>? autofillHints;
  final TextInputAction textInputAction;
  final VoidCallback? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final style = AppTextFieldStyle(context);
    final icon = prefixIcon;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      enabled: enabled,
      // A field that hides its text must be single line.
      maxLines: obscureText ? 1 : maxLines,
      autofillHints: autofillHints,
      textInputAction: textInputAction,
      validator: validator,
      style: style.textStyle,
      onFieldSubmitted: onSubmitted == null ? null : (_) => onSubmitted!(),
      // `tr(context:)` depends on Localizations, so the label follows the
      // current language without any extra listener.
      decoration: style.decoration(
        label: labelKey.tr(context: context),
        hint: hintKey?.tr(context: context),
        prefix: icon == null
            ? null
            : AppIcon(icon, color: style.iconColor),
        suffix: suffix,
      ),
    );
  }
}
