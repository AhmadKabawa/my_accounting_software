import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/core/foundation/validation/app_validator.dart';
import 'package:accounting_software/app/core/localization/keys/field_keys.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/message_view_widgets.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_page_template/app_page_templates.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/features/auth/presentation/cubit/force_password/force_password_change_cubit.dart';
import 'package:accounting_software/app/features/auth/presentation/cubit/session/session_cubit.dart';
import 'package:accounting_software/app/features/auth/presentation/localization/auth_keys.dart';
import 'package:accounting_software/app/features/auth/presentation/widgets/password_field.dart';

class ForcePasswordChangeScreen extends StatefulWidget {
  const ForcePasswordChangeScreen({super.key});

  @override
  State<ForcePasswordChangeScreen> createState() =>
      _ForcePasswordChangeScreenState();
}

class _ForcePasswordChangeScreenState extends State<ForcePasswordChangeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();

  @override
  void dispose() {
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  void _submit() {
    MessageViewWidgets.hideKeyboard();
    if (!_formKey.currentState!.validate()) return;
    context.read<ForcePasswordChangeCubit>().submit(_password.text);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ForcePasswordChangeCubit, ForcePasswordChangeState>(
      builder: (context, state) {
        final saving = state.status == ForcePasswordChangeStatus.saving;
        return Scaffold(
          body: SafeArea(
            child: FormPageTemplate(
              titleKey: AuthKeys.forceChangePasswordTitle,
              saving: saving,
              onSave: _submit,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const AppText(
                      AuthKeys.forceChangePasswordSubtitle,
                      type: AppTextType.bodyMedium,
                    ),
                    context.ui.spacing.gap(AppSpacing.lg, axis: Axis.vertical),
                    if (state.failure != null) ...[
                      MessageViewWidgets.failureBanner(state.failure!),
                      context.ui.spacing.gap(
                        AppSpacing.md,
                        axis: Axis.vertical,
                      ),
                    ],
                    PasswordField(
                      controller: _password,
                      labelKey: FieldKeys.newPassword,
                      validator: (value) => AppValidator.validate(value, [
                        ValidationRule.required,
                        ValidationRule.password,
                      ]),
                    ),
                    context.ui.spacing.gap(AppSpacing.md, axis: Axis.vertical),
                    PasswordField(
                      controller: _confirmation,
                      labelKey: FieldKeys.confirmPassword,
                      textInputAction: TextInputAction.done,
                      onSubmitted: _submit,
                      validator: (value) => AppValidator.validate(
                        value,
                        [ValidationRule.required, ValidationRule.match],
                        params: {ValidationRule.match: _password.text},
                      ),
                    ),
                    context.ui.spacing.gap(AppSpacing.xl, axis: Axis.vertical),
                    AppButton(
                      AuthKeys.signOut,
                      variant: AppButtonVariant.danger,
                      expand: true,
                      onPressed: () =>
                          context.read<SessionCubit>().signOutWithResult(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
