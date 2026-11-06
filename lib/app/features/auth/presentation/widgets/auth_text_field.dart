import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';

/// A labelled form field for the auth pages. The label is an [AppKey] resolved
/// at build time, so it follows the current language. Validation is supplied
/// by the caller through `AppValidator`.
class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.controller,
    required this.labelKey,
    required this.validator,
    this.icon,
    this.keyboardType,
    this.obscureText = false,
    this.suffix,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final AppKey labelKey;
  final String? Function(String?) validator;
  final IconData? icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffix;
  final TextInputAction textInputAction;
  final VoidCallback? onSubmitted;

  @override
  Widget build(BuildContext context) {
    context.locale; // rebuild when the language changes
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      textInputAction: textInputAction,
      validator: validator,
      onFieldSubmitted: onSubmitted == null ? null : (_) => onSubmitted!(),
      decoration: InputDecoration(
        labelText: labelKey.tr(),
        prefixIcon: icon == null ? null : Icon(icon),
        suffixIcon: suffix,
      ),
    );
  }
}
