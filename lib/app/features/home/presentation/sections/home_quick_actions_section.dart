import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/core/access/permission.dart';
import 'package:accounting_software/app/core/access/permission_gate/permission_gate.dart';
import 'package:accounting_software/app/core/access/permissions.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_card/app_card.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon_data.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icons.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/features/home/presentation/cubit/home_cubit.dart';
import 'package:accounting_software/app/features/home/presentation/localization/home_keys.dart';

class _Action {
  const _Action(this.label, this.icon, this.permission);

  final AppKey label;
  final AppIconData icon;
  final Permission permission;
}

/// Shortcuts to the main jobs. Each one is shown only to roles allowed to do
/// it (visibility only; the server enforces the permission).
class HomeQuickActionsSection extends StatelessWidget {
  const HomeQuickActionsSection({super.key});

  static final _actions = [
    _Action(HomeKeys.newSale, AppIcons.sale, Permissions.sales.create),
    _Action(
      HomeKeys.newPurchase,
      AppIcons.purchase,
      Permissions.purchases.create,
    ),
    _Action(
      HomeKeys.receivePayment,
      AppIcons.payment,
      Permissions.payments.create,
    ),
    _Action(HomeKeys.customers, AppIcons.customers, Permissions.customers.view),
    _Action(HomeKeys.reports, AppIcons.reports, Permissions.reports.view),
  ];

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<HomeCubit>();
    return Wrap(
      spacing: context.ui.spacing.value(AppSpacing.md),
      runSpacing: context.ui.spacing.value(AppSpacing.md),
      children: [
        for (final action in _actions)
          PermissionGate(
            permission: action.permission,
            child: SizedBox(
              width: context.ui.size.width(AppComponentSize.cardWidth) / 2,
              child: AppCard(
                onTap: () => cubit.openAction(action.label),
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
