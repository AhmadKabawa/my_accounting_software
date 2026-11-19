import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/core/access/cubit/access_cubit.dart';
import 'package:accounting_software/app/core/access/models/access_snapshot.dart';
import 'package:accounting_software/app/core/localization/keys/scope_keys.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_badge/app_badge.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_card/app_card.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/features/auth/presentation/localization/auth_keys.dart';
import 'package:accounting_software/app/features/auth/presentation/widgets/auth_page_scaffold.dart';

/// AUTH-03. Needs an `AccessCubit` above it. Shown only when the user can view
/// more than one branch and has not chosen one; the router leaves this page as
/// soon as `selectedBranchId` is set (the redirect rule, not this widget).
class SelectBranchScreen extends StatefulWidget {
  const SelectBranchScreen({super.key});

  @override
  State<SelectBranchScreen> createState() => _SelectBranchScreenState();
}

class _SelectBranchScreenState extends State<SelectBranchScreen> {
  int? _chosenId;

  @override
  Widget build(BuildContext context) {
    final access = context.watch<AccessCubit>().state;
    final branches = (access.snapshot?.branches ?? const <AccessBranch>[])
        .where((branch) => branch.canView)
        .toList(growable: false);
    final loading = access.status == AccessStatus.loading;

    return AuthPageScaffold(
      titleKey: AuthKeys.selectBranchTitle,
      subtitleKey: AuthKeys.selectBranchSubtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final branch in branches) ...[
            _BranchCard(
              branch: branch,
              selected: branch.id == _chosenId,
              onTap: loading
                  ? null
                  : () => setState(() => _chosenId = branch.id),
            ),
            context.ui.spacing.gap(AppSpacing.sm, axis: Axis.vertical),
          ],
          context.ui.spacing.gap(AppSpacing.sm, axis: Axis.vertical),
          AppButton(
            AuthKeys.continueAction,
            expand: true,
            isLoading: loading,
            onPressed: _chosenId == null || loading
                ? null
                : () => context.read<AccessCubit>().selectBranch(_chosenId!),
          ),
        ],
      ),
    );
  }
}

class _BranchCard extends StatelessWidget {
  const _BranchCard({
    required this.branch,
    required this.selected,
    required this.onTap,
  });

  final AccessBranch branch;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      child: AppCard(
        onTap: onTap,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.raw(branch.name, type: AppTextType.titleMedium),
                  if (!branch.canOperate) ...[
                    context.ui.spacing.gap(AppSpacing.xs, axis: Axis.vertical),
                    const AppBadge(
                      label: ScopeKeys.viewOnly,
                      tone: AppBadgeTone.warning,
                      size: AppBadgeSize.small,
                    ),
                  ],
                ],
              ),
            ),
            if (selected) const AppIcon(AppIcons.check),
          ],
        ),
      ),
    );
  }
}
