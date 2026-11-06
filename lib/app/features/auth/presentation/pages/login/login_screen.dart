import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/localization/translations/app_keys.dart';
import 'package:accounting_software/app/features/auth/presentation/pages/login/widgets/login_form_section.dart';
import 'package:accounting_software/app/features/auth/presentation/widgets/auth_page_scaffold.dart';

/// Needs an `AuthCubit` above it (provided by the router).
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthPageScaffold(
      titleKey: AppKeys.auth.loginTitle,
      subtitleKey: AppKeys.auth.loginSubtitle,
      child: const LoginFormSection(),
    );
  }
}
