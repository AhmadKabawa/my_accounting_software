import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:accounting_software/app/core/foundation/validation/app_validator.dart';
import 'package:accounting_software/app/features/auth/presentation/localization/auth_keys.dart';
import 'package:accounting_software/app/core/localization/keys/field_keys.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/message_view_widgets.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_divider/app_divider.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text_field/app_text_field.dart';
import 'package:accounting_software/app/features/auth/presentation/cubit/auth_flow/auth_flow_cubit.dart';
import 'package:accounting_software/app/features/auth/presentation/routing/auth_routes.dart';
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
    context.read<AuthFlowCubit>().signInWithEmail(
      email: _email.text.trim(),
      password: _password.text,
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
          PasswordField(
            controller: _password,
            labelKey: FieldKeys.password,
            textInputAction: TextInputAction.done,
            onSubmitted: loading ? null : _submit,
            // No complexity rules at sign-in: only the server judges the password.
            validator: (v) =>
                AppValidator.validate(v, [ValidationRule.required]),
          ),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: AppButton(
              AuthKeys.forgotPassword,
              variant: AppButtonVariant.text,
              size: AppButtonSize.small,
              onPressed: () => context.pushNamed(AuthRoutes.forgotPassword.name),
            ),
          ),
          gap,
          AppButton(
            AuthKeys.signIn,
            expand: true,
            isLoading: loading,
            onPressed: _submit,
          ),
          gap,
          const AppDivider(labelKey: AuthKeys.orSignInWith),
          gap,
          GoogleSignInButton(
            isLoading: loading,
            onPressed: () => context.read<AuthFlowCubit>().signInWithGoogle(),
          ),
          gap,
          AppButton(
            AuthKeys.noAccount,
            variant: AppButtonVariant.text,
            size: AppButtonSize.small,
            onPressed: () => context.pushNamed(AuthRoutes.register.name),
          ),
        ],
      ),
    );
  }
}
