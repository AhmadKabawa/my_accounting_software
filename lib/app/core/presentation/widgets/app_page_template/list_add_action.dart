import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/access/permission.dart';
import 'package:accounting_software/app/core/access/permission_gate/permission_gate.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';

/// Localized, permission-scoped create action shared by list page slots.
class ListAddAction {
  const ListAddAction({
    required this.labelKey,
    required this.permission,
    required this.onPressed,
    this.icon = AppIcons.add,
  });

  final AppKey labelKey;
  final Permission permission;
  final VoidCallback onPressed;
  final AppIconData icon;
}

/// The only place that builds the standard add button for list pages.
class ListAddButton extends StatelessWidget {
  const ListAddButton({super.key, required this.action});

  final ListAddAction action;

  @override
  Widget build(BuildContext context) => PermissionGate(
    permission: action.permission,
    child: AppButton(
      action.labelKey,
      icon: action.icon,
      onPressed: action.onPressed,
    ),
  );
}
