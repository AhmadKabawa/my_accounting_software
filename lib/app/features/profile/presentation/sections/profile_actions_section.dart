import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/features/auth/presentation/localization/auth_keys.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_button.dart';
import 'package:accounting_software/app/features/auth/presentation/cubit/session/session_cubit.dart';

/// Account actions. Signing out moves the session to unauthenticated and the
/// router sends the user to the login page.
class ProfileActionsSection extends StatefulWidget {
  const ProfileActionsSection({super.key});

  @override
  State<ProfileActionsSection> createState() => _ProfileActionsSectionState();
}

class _ProfileActionsSectionState extends State<ProfileActionsSection> {
  // Local loading: the app-wide session never enters a "loading" state.
  bool _signingOut = false;

  Future<void> _signOut() async {
    setState(() => _signingOut = true);
    await context.read<SessionCubit>().signOut();
    if (mounted) setState(() => _signingOut = false);
  }

  @override
  Widget build(BuildContext context) {
    return AppButton(
      AuthKeys.signOut,
      variant: AppButtonVariant.danger,
      icon: AppIcons.logout,
      expand: true,
      isLoading: _signingOut,
      onPressed: _signOut,
    );
  }
}
