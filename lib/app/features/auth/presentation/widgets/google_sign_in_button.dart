import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/core/localization/translations/app_keys.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_button.dart';
import 'package:accounting_software/app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:accounting_software/app/features/auth/presentation/cubit/states/auth_states.dart';

/// "Continue with Google" — the only social provider the data layer
/// implements (`signInWithGoogle`), so it is the only one shown.
class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({super.key});

  @override
  Widget build(BuildContext context) {
    final loading = context.select<AuthCubit, bool>(
      (cubit) => cubit.state is AuthLoading,
    );
    return AppButton(
      AppKeys.auth.continueGoogle,
      variant: AppButtonVariant.outlined,
      icon: Icons.account_circle_outlined,
      expand: true,
      isLoading: loading,
      onPressed: () => context.read<AuthCubit>().signInWithGoogle(),
    );
  }
}
