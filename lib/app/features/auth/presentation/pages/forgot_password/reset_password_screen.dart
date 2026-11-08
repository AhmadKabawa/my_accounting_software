import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:accounting_software/app/core/foundation/validation/app_validator.dart';
import 'package:accounting_software/app/features/auth/presentation/localization/auth_keys.dart';
import 'package:accounting_software/app/core/localization/keys/field_keys.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/message_view_widgets.dart';
import 'package:accounting_software/app/core/presentation/state_management/bloc_effect_listener.dart';
import 'package:accounting_software/app/features/auth/presentation/cubit/auth_flow/auth_flow_cubit.dart';
import 'package:accounting_software/app/features/auth/presentation/cubit/auth_flow/auth_flow_effect.dart';
import 'package:accounting_software/app/features/auth/presentation/routing/auth_routes.dart';
import 'package:accounting_software/app/features/auth/presentation/widgets/auth_page_scaffold.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text_field/app_text_field.dart';
import 'package:accounting_software/app/features/auth/presentation/widgets/password_field.dart';

/// Step 2 of password recovery: the e-mailed code and the new password.
/// Supabase verifies the code and sets the password in one call
/// (`confirmNewPassword`), so there is no separate "verify code" page.
class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key, required this.email});

  final String email;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _code = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _code.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _submit() {
    MessageViewWidgets.hideKeyboard();
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthFlowCubit>().confirmNewPassword(
      email: widget.email,
      code: _code.text.trim(),
      newPassword: _password.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final gap = context.ui.spacing.gap(AppSpacing.md, axis: Axis.vertical);

    return BlocEffectListener<AuthFlowEffect, AuthFlowCubit>(
      onEffect: (context, effect) {
        if (effect is PasswordResetEffect) {
          context.goNamed(AuthRoutes.login.name);
        }
      },
      child: AuthPageScaffold(
        titleKey: AuthKeys.resetPasswordTitle,
        subtitleKey: AuthKeys.resetPasswordSubtitle,
        showBack: true,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                controller: _code,
                labelKey: FieldKeys.resetCode,
                prefixIcon: AppIcons.pin,
                keyboardType: TextInputType.number,
                validator: (v) =>
                    AppValidator.validate(v, [ValidationRule.required]),
              ),
              gap,
              PasswordField(
                controller: _password,
                labelKey: FieldKeys.newPassword,
                validator: (v) => AppValidator.validate(v, [
                  ValidationRule.required,
                  ValidationRule.password,
                ]),
              ),
              gap,
              PasswordField(
                controller: _confirm,
                labelKey: FieldKeys.confirmPassword,
                textInputAction: TextInputAction.done,
                onSubmitted: _submit,
                validator: (v) => AppValidator.validate(
                  v,
                  [ValidationRule.required, ValidationRule.match],
                  params: {ValidationRule.match: _password.text},
                ),
              ),
              gap,
              AppButton(
                AuthKeys.resetPassword,
                expand: true,
                isLoading: context.select<AuthFlowCubit, bool>(
                  (c) => c.isLoading,
                ),
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
