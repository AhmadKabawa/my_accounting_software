import 'package:flutter/material.dart';
import 'package:accounting_software/app/features/auth/presentation/localization/auth_keys.dart';
import 'package:accounting_software/app/features/auth/presentation/pages/signup/sections/sign_up_form_section.dart';
import 'package:accounting_software/app/features/auth/presentation/widgets/auth_page_scaffold.dart';

/// Needs an `AuthFlowCubit` above it (provided by the router per page).
class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthPageScaffold(
      titleKey: AuthKeys.registerTitle,
      subtitleKey: AuthKeys.registerSubtitle,
      showBack: true,
      child: const SignUpFormSection(),
    );
  }
}
