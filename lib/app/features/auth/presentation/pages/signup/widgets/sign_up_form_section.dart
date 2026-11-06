import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:accounting_software/app/core/foundation/validation/app_validator.dart';
import 'package:accounting_software/app/core/localization/translations/app_keys.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/message_view_widgets.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/core/routing/routes.dart';
import 'package:accounting_software/app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:accounting_software/app/features/auth/presentation/cubit/states/auth_states.dart';
import 'package:accounting_software/app/features/auth/presentation/widgets/auth_divider.dart';
import 'package:accounting_software/app/features/auth/presentation/widgets/auth_text_field.dart';
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
    context.read<AuthCubit>().signUpWithEmail(
      email: _email.text.trim().toLowerCase(),
      password: _password.text,
      fullName: _name.text.trim(),
      phone: phone.isEmpty ? null : phone,
    );
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.select<AuthCubit, bool>(
      (cubit) => cubit.state is AuthLoading,
    );
    final gap = context.ui.spacing.gap(AppSpacing.md, axis: Axis.vertical);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthTextField(
            controller: _name,
            labelKey: AppKeys.fields.fullName,
            icon: Icons.person_outline,
            validator: (v) => AppValidator.validate(
              v,
              [ValidationRule.required, ValidationRule.minLength],
              params: {ValidationRule.minLength: 2},
            ),
          ),
          gap,
          AuthTextField(
            controller: _email,
            labelKey: AppKeys.fields.email,
            icon: Icons.mail_outline,
            keyboardType: TextInputType.emailAddress,
            validator: (v) => AppValidator.validate(v, [
              ValidationRule.required,
              ValidationRule.email,
            ]),
          ),
          gap,
          AuthTextField(
            controller: _phone,
            labelKey: AppKeys.fields.phone,
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            // Optional: validated only when something was typed.
            validator: (v) => (v == null || v.trim().isEmpty)
                ? null
                : AppValidator.validate(v, [ValidationRule.phone]),
          ),
          gap,
          PasswordField(
            controller: _password,
            labelKey: AppKeys.fields.password,
            validator: (v) => AppValidator.validate(v, [
              ValidationRule.required,
              ValidationRule.password,
            ]),
          ),
          gap,
          PasswordField(
            controller: _confirm,
            labelKey: AppKeys.fields.confirmPassword,
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
            AppKeys.auth.createAccount,
            expand: true,
            isLoading: loading,
            onPressed: _submit,
          ),
          gap,
          const AuthDivider(textKey: AppKeys.auth.orSignUpWith),
          gap,
          const GoogleSignInButton(),
          gap,
          TextButton(
            onPressed: () => context.goNamed(AppRoutes.login.name),
            child: AppText(
              AppKeys.auth.haveAccount,
              type: AppTextType.labelLarge,
            ),
          ),
        ],
      ),
    );
  }
}
