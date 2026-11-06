import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:accounting_software/app/core/foundation/validation/app_validator.dart';
import 'package:accounting_software/app/core/localization/translations/app_keys.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/message_view_widgets.dart';
import 'package:accounting_software/app/core/routing/routes.dart';
import 'package:accounting_software/app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:accounting_software/app/features/auth/presentation/cubit/states/auth_states.dart';
import 'package:accounting_software/app/features/auth/presentation/widgets/auth_page_scaffold.dart';
import 'package:accounting_software/app/features/auth/presentation/widgets/auth_text_field.dart';

/// Step 1 of password recovery: ask for the e-mail, then continue to the
/// reset page once the code has been sent.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _submit() {
    MessageViewWidgets.hideKeyboard();
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthCubit>().sendResetCode(email: _email.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (_, current) => current is ResetCodeSent,
      listener: (context, state) {
        if (state is! ResetCodeSent) return;
        context.pushNamed(
          AppRoutes.resetPassword.name,
          queryParameters: {'email': state.email},
        );
      },
      child: AuthPageScaffold(
        titleKey: AppKeys.auth.forgetPassword,
        subtitleKey: AppKeys.auth.forgotPasswordSubtitle,
        showBack: true,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthTextField(
                controller: _email,
                labelKey: AppKeys.fields.email,
                icon: Icons.mail_outline,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                onSubmitted: _submit,
                validator: (v) => AppValidator.validate(v, [
                  ValidationRule.required,
                  ValidationRule.email,
                ]),
              ),
              context.ui.spacing.gap(AppSpacing.md, axis: Axis.vertical),
              AppButton(
                AppKeys.auth.sendCode,
                expand: true,
                isLoading: context.select<AuthCubit, bool>(
                  (c) => c.state is AuthLoading,
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
