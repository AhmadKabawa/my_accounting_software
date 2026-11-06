import 'package:flutter/material.dart';
import 'package:accounting_software/app/features/auth/presentation/localization/auth_keys.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_button.dart';

/// "Continue with Google" — the only social provider the data layer
/// implements (`signInWithGoogle`), so it is the only one shown.
///
/// No logic: the page decides what a press does and whether it is loading.
class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  final VoidCallback onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return AppButton(
      AuthKeys.continueGoogle,
      variant: AppButtonVariant.outlined,
      icon: AppIcons.google,
      expand: true,
      isLoading: isLoading,
      onPressed: onPressed,
    );
  }
}
