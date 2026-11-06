import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/core/localization/translations/app_keys.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_button.dart';
import 'package:accounting_software/app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:accounting_software/app/features/auth/presentation/cubit/states/auth_states.dart';

/// Account actions. Signing out moves the auth state to Unauthenticated and
/// the router sends the user to the login page.
class ProfileActionsSection extends StatelessWidget {
  const ProfileActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final loading = context.select<AuthCubit, bool>(
      (cubit) => cubit.state is AuthLoading,
    );
    return AppButton(
      AppKeys.auth.signOut,
      variant: AppButtonVariant.danger,
      icon: Icons.logout,
      expand: true,
      isLoading: loading,
      onPressed: () => context.read<AuthCubit>().signOut(),
    );
  }
}
