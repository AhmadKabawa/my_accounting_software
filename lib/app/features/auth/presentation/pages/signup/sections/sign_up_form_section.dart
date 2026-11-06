import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:accounting_software/app/core/foundation/validation/app_validator.dart';
import 'package:accounting_software/app/features/auth/presentation/localization/auth_keys.dart';
import 'package:accounting_software/app/core/localization/keys/field_keys.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/message_view_widgets.dart';
import 'package:accounting_software/app/core/routing/routes.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_divider/app_divider.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text_field/app_text_field.dart';
import 'package:accounting_software/app/features/auth/presentation/cubit/auth_flow/auth_flow_cubit.dart';
import 'package:accounting_software/app/features/auth/presentation/widgets/google_sign_in_button.dart';
import 'package:accounting_software/app/features/auth/presentation/widgets/password_field.dart';

class SignUpFormSection extends StatefulWidget {
  const SignUpFormSection({super.key});

  @override
  State<SignUpFormSection> createState() => _SignUpFormSectionState();
}

class _SignUpFormSectionState extends State<SignUpFormSection> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _submit() {
    MessageViewWidgets.hideKeyboard();
    if (!_formKey.currentState!.validate()) return;
    final phone = _phone.text.trim();
    context.read<AuthFlowCubit>().signUpWithEmail(
      email: _email.text.trim().toLowerCase(),
      password: _password.text,
      fullName: _name.text.trim(),
      phone: phone.isEmpty ? null : phone,
    );
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.select<AuthFlowCubit, bool>(
      (cubit) => cubit.isLoading,
    );
    final gap = context.ui.spacing.gap(AppSpacing.md, axis: Axis.vertical);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            controller: _name,
            labelKey: FieldKeys.fullName,
            prefixIcon: AppIcons.person,
            validator: (v) => AppValidator.validate(
              v,
              [ValidationRule.required, ValidationRule.minLength],
              params: {ValidationRule.minLength: 2},
            ),
          ),
          gap,
          AppTextField(
            controller: _email,
            labelKey: FieldKeys.email,
            prefixIcon: AppIcons.email,
            keyboardType: TextInputType.emailAddress,
            validator: (v) => AppValidator.validate(v, [
              ValidationRule.required,
              ValidationRule.email,
            ]),
          ),
          gap,
          AppTextField(
            controller: _phone,
            labelKey: FieldKeys.phone,
            prefixIcon: AppIcons.phone,
            keyboardType: TextInputType.phone,
            // Optional: validated only when something was typed.
            validator: (v) => (v == null || v.trim().isEmpty)
                ? null
                : AppValidator.validate(v, [ValidationRule.phone]),
          ),
          gap,
          PasswordField(
            controller: _password,
            labelKey: FieldKeys.password,
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
            onSubmitted: loading ? null : _submit,
            validator: (v) => AppValidator.validate(
              v,
              [ValidationRule.required, ValidationRule.match],
              params: {ValidationRule.match: _password.text},
            ),
          ),
          gap,
          AppButton(
            AuthKeys.createAccount,
            expand: true,
            isLoading: loading,
            onPressed: _submit,
          ),
          gap,
          const AppDivider(labelKey: AuthKeys.orSignUpWith),
          gap,
          GoogleSignInButton(
            isLoading: loading,
            onPressed: () => context.read<AuthFlowCubit>().signInWithGoogle(),
          ),
          gap,
          AppButton(
            AuthKeys.haveAccount,
            variant: AppButtonVariant.text,
            size: AppButtonSize.small,
            onPressed: () => context.goNamed(AppRoutes.login.name),
          ),
        ],
      ),
    );
  }
}
