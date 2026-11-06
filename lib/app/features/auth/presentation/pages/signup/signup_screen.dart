import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/localization/translations/app_keys.dart';
import 'package:accounting_software/app/features/auth/presentation/pages/signup/widgets/sign_up_form_section.dart';
import 'package:accounting_software/app/features/auth/presentation/widgets/auth_page_scaffold.dart';

/// Needs an `AuthCubit` above it (provided by the router).
class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthPageScaffold(
      titleKey: AppKeys.auth.registerTitle,
      subtitleKey: AppKeys.auth.registerSubtitle,
      showBack: true,
      child: const SignUpFormSection(),
    );
  }
}
