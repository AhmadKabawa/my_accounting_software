import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/features/auth/presentation/localization/auth_keys.dart';
import 'package:accounting_software/app/features/auth/presentation/pages/login/sections/login_form_section.dart';
import 'package:accounting_software/app/features/auth/presentation/widgets/auth_page_scaffold.dart';

/// AUTH-01. Needs an `AuthFlowCubit` above it (provided by the router per
/// page). The brand is a plain-text wordmark: v1 has no logo asset.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AuthPageScaffold(
      header: Center(
        child: AppText.raw('vaude', type: AppTextType.displaySmall),
      ),
      titleKey: AuthKeys.loginTitle,
      subtitleKey: AuthKeys.loginSubtitle,
      child: LoginFormSection(),
    );
  }
}
