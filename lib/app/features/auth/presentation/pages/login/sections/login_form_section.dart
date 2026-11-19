import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:accounting_software/app/core/foundation/config/app_config.dart';
import 'package:accounting_software/app/core/foundation/validation/app_validator.dart';
import 'package:accounting_software/app/features/auth/presentation/localization/auth_keys.dart';
import 'package:accounting_software/app/core/localization/keys/field_keys.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_button.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/state_management/bloc_effect_listener.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_inline_banner/inline_banner.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/message_view_widgets.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_divider/app_divider.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text_field/app_text_field.dart';
import 'package:accounting_software/app/features/auth/presentation/cubit/auth_flow/auth_flow_cubit.dart';
import 'package:accounting_software/app/features/auth/presentation/cubit/auth_flow/auth_flow_effect.dart';
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
  final _username = TextEditingController();
  final _password = TextEditingController();

  /// The rejection of the last attempt, shown in one banner above the fields
  /// (C38). Cleared on the next attempt or when the person closes it.
  AppKey? _errorKey;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    MessageViewWidgets.hideKeyboard();
    if (!_formKey.currentState!.validate()) return;
    setState(() => _errorKey = null);
    context.read<AuthFlowCubit>().signIn(
      identifier: _username.text.trim(),
      password: _password.text,
    );
  }

  void _onEffect(BuildContext context, AuthFlowEffect effect) {
    if (effect is SignInFailedEffect) {
      setState(() => _errorKey = effect.messageKey);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.select<AuthFlowCubit, bool>(
      (cubit) => cubit.isLoading,
    );
    final gap = context.ui.spacing.gap(AppSpacing.md, axis: Axis.vertical);

    return BlocEffectListener<AuthFlowEffect, AuthFlowCubit>(
      onEffect: _onEffect,
      child: Form(
        key: _formKey,
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_errorKey != null) ...[
                InlineBanner(
                  messageKey: _errorKey!,
                  variant: InlineBannerVariant.error,
                  onDismiss: () => setState(() => _errorKey = null),
                ),
                gap,
              ],
              AppTextField(
                controller: _username,
                labelKey: FieldKeys.username,
                prefixIcon: AppIcons.person,
                keyboardType: TextInputType.text,
                autofillHints: const [AutofillHints.username],
                // A username, not an e-mail: only "required" is checked here.
                validator: (v) =>
                    AppValidator.validate(v, [ValidationRule.required]),
              ),
              gap,
              PasswordField(
                controller: _password,
                labelKey: FieldKeys.password,
                textInputAction: TextInputAction.done,
                onSubmitted: loading ? null : _submit,
                // No complexity rules at sign-in: only the server judges it.
                validator: (v) =>
                    AppValidator.validate(v, [ValidationRule.required]),
              ),
              if (AppConfig.forgotPasswordEnabled)
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: AppButton(
                    AuthKeys.forgotPassword,
                    variant: AppButtonVariant.text,
                    size: AppButtonSize.small,
                    onPressed: () =>
                        context.pushNamed(AuthRoutes.forgotPassword.name),
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
              if (!AppConfig.forgotPasswordEnabled)
                const AppText(
                  AuthKeys.contactAdmin,
                  type: AppTextType.bodySmall,
                  textAlign: TextAlign.center,
                ),
              if (AppConfig.googleSignInEnabled) ...[
                const AppDivider(labelKey: AuthKeys.orSignInWith),
                gap,
                GoogleSignInButton(
                  isLoading: loading,
                  onPressed: () =>
                      context.read<AuthFlowCubit>().signInWithGoogle(),
                ),
              ],
              if (AppConfig.signupEnabled) ...[
                gap,
                AppButton(
                  AuthKeys.noAccount,
                  variant: AppButtonVariant.text,
                  size: AppButtonSize.small,
                  onPressed: () => context.pushNamed(AuthRoutes.register.name),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
