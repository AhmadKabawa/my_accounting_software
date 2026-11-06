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

class LoginFormSection extends StatefulWidget {
  const LoginFormSection({super.key});

  @override
  State<LoginFormSection> createState() => _LoginFormSectionState();
}

class _LoginFormSectionState extends State<LoginFormSection> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    MessageViewWidgets.hideKeyboard();
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthCubit>().signInWithEmail(
      email: _email.text.trim(),
      password: _password.text,
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
          PasswordField(
            controller: _password,
            labelKey: AppKeys.fields.password,
            textInputAction: TextInputAction.done,
            onSubmitted: loading ? null : _submit,
            // No complexity rules at sign-in: only the server judges the password.
            validator: (v) =>
                AppValidator.validate(v, [ValidationRule.required]),
          ),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton(
              onPressed: () => context.pushNamed(AppRoutes.forgotPassword.name),
              child: AppText(
                AppKeys.auth.forgotPassword,
                type: AppTextType.labelLarge,
              ),
            ),
          ),
          gap,
          AppButton(
            AppKeys.auth.signIn,
            expand: true,
            isLoading: loading,
            onPressed: _submit,
          ),
          gap,
          const AuthDivider(textKey: AppKeys.auth.orSignInWith),
          gap,
          const GoogleSignInButton(),
          gap,
          TextButton(
            onPressed: () => context.pushNamed(AppRoutes.register.name),
            child: AppText(
              AppKeys.auth.noAccount,
              type: AppTextType.labelLarge,
            ),
          ),
        ],
      ),
    );
  }
}
