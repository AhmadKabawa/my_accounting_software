import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/core/access/permission_gate/permission_gate.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_card/app_card.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/features/home/presentation/cubit/home_cubit.dart';
import 'package:accounting_software/app/features/home/presentation/model/quick_action.dart';

/// Shortcuts to the main jobs. Each one is shown only to roles allowed to do
/// it (visibility only; the server enforces the permission).
class HomeQuickActionsSection extends StatelessWidget {
  const HomeQuickActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<HomeCubit>();
    return Wrap(
      spacing: context.ui.spacing.value(AppSpacing.md),
      runSpacing: context.ui.spacing.value(AppSpacing.md),
      children: [
        for (final action in QuickAction.values)
          PermissionGate(
            permission: action.permission,
            child: SizedBox(
              width: context.ui.size.width(AppComponentSize.cardWidth) / 2,
              child: AppCard(
                onTap: () => cubit.openAction(action),
                child: Column(
                  children: [
                    AppIcon(
                      action.icon,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    context.ui.spacing.gap(
                      AppSpacing.sm,
                      axis: Axis.vertical,
                    ),
                    AppText(
                      action.label,
                      type: AppTextType.labelMedium,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
