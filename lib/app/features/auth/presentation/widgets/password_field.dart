import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_icon_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text_field/app_text_field.dart';
import 'package:accounting_software/app/features/auth/presentation/localization/auth_keys.dart';

/// A password [AppTextField] with a show/hide toggle (an `AppIconButton`).
class PasswordField extends StatefulWidget {
  const PasswordField({
    super.key,
    required this.controller,
    required this.labelKey,
    required this.validator,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final AppKey labelKey;
  final String? Function(String?) validator;
  final TextInputAction textInputAction;
  final VoidCallback? onSubmitted;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: widget.controller,
      labelKey: widget.labelKey,
      validator: widget.validator,
      prefixIcon: AppIcons.lock,
      keyboardType: TextInputType.visiblePassword,
      obscureText: _obscure,
      textInputAction: widget.textInputAction,
      onSubmitted: widget.onSubmitted,
      suffix: AppIconButton(
        _obscure ? AppIcons.visibilityOff : AppIcons.visibility,
        tooltipKey: _obscure ? AuthKeys.showPassword : AuthKeys.hidePassword,
        onPressed: () => setState(() => _obscure = !_obscure),
      ),
    );
  }
}
