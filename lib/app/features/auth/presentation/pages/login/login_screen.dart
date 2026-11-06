import 'package:flutter/material.dart';
import 'package:accounting_software/app/features/auth/presentation/localization/auth_keys.dart';
import 'package:accounting_software/app/features/auth/presentation/pages/login/sections/login_form_section.dart';
import 'package:accounting_software/app/features/auth/presentation/widgets/auth_page_scaffold.dart';

/// Needs an `AuthFlowCubit` above it (provided by the router per page).
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthPageScaffold(
      titleKey: AuthKeys.loginTitle,
      subtitleKey: AuthKeys.loginSubtitle,
      child: const LoginFormSection(),
    );
  }
}
