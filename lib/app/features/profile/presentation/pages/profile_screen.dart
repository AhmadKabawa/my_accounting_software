import 'package:flutter/material.dart';
import 'package:accounting_software/app/features/profile/presentation/localization/profile_keys.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_appbar/app_page_app_bar.dart';
import 'package:accounting_software/app/features/profile/presentation/sections/profile_actions_section.dart';
import 'package:accounting_software/app/features/profile/presentation/sections/profile_header_section.dart';

/// Needs a `SessionCubit` above it (provided by the router). The screen only
/// arranges its sections; each section reads what it needs.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppPageAppBar(titleKey: ProfileKeys.title),
      body: ListView(
        padding: context.ui.padding.all(AppSpacing.lg),
        children: [
          const ProfileHeaderSection(),
          context.ui.spacing.gap(AppSpacing.xl, axis: Axis.vertical),
          const ProfileActionsSection(),
        ],
      ),
    );
  }
}
