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
    context.read<AuthFlowCubit>().sendResetCode(email: _email.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return BlocEffectListener<AuthFlowEffect, AuthFlowCubit>(
      onEffect: (context, effect) {
        if (effect is! ResetCodeSentEffect) return;
        context.pushNamed(
          AuthRoutes.resetPassword.name,
          queryParameters: {'email': effect.email},
        );
      },
      child: AuthPageScaffold(
        titleKey: AuthKeys.forgotPasswordTitle,
        subtitleKey: AuthKeys.forgotPasswordSubtitle,
        showBack: true,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                controller: _email,
                labelKey: FieldKeys.email,
                prefixIcon: AppIcons.email,
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
                AuthKeys.sendCode,
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
