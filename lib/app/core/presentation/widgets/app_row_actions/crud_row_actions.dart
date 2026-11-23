import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/access/permission.dart';
import 'package:accounting_software/app/core/access/permission_gate/permission_gate.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_table/data_table.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_row_actions/app_row_actions.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_switch/app_switch.dart';

/// CRUD row actions shared by table, card and grid representations.
class CrudRowActions extends StatelessWidget {
  const CrudRowActions({
    super.key,
    required this.permission,
    required this.editLabelKey,
    required this.onEdit,
    required this.deleteLabelKey,
    required this.onDelete,
    this.duplicateLabelKey,
    this.onDuplicate,
    this.isActive,
    this.onToggleStatus,
    this.activateLabelKey,
    this.deactivateLabelKey,
    this.extraOverflow = const [],
  });

  final Permission permission;
  final AppKey editLabelKey;
  final VoidCallback onEdit;
  final AppKey deleteLabelKey;

  /// Null disables deletion but keeps its menu item visible.
  final VoidCallback? onDelete;
  final AppKey? duplicateLabelKey;
  final VoidCallback? onDuplicate;
  final bool? isActive;
  final VoidCallback? onToggleStatus;
  final AppKey? activateLabelKey;
  final AppKey? deactivateLabelKey;
  final List<AppRowAction> extraOverflow;

  @override
  Widget build(BuildContext context) => PermissionGate(
    permission: permission,
    child: AppRowActions(
      primary: [
        AppRowAction(
          icon: AppIcons.edit,
          labelKey: editLabelKey,
          onPressed: onEdit,
        ),
      ],
      overflow: [
        if (isActive != null &&
            onToggleStatus != null &&
            activateLabelKey != null &&
            deactivateLabelKey != null)
          AppRowAction(
            icon: isActive! ? AppIcons.block : AppIcons.restore,
            labelKey: isActive! ? deactivateLabelKey! : activateLabelKey!,
            onPressed: onToggleStatus,
          ),
        if (onDuplicate != null && duplicateLabelKey != null)
          AppRowAction(
            icon: AppIcons.copy,
            labelKey: duplicateLabelKey!,
            onPressed: onDuplicate,
          ),
        ...extraOverflow,
        AppRowAction(
          icon: AppIcons.delete,
          labelKey: deleteLabelKey,
          destructive: true,
          onPressed: onDelete,
        ),
      ],
    ),
  );
}

/// The shared status column: a permission-gated switch or a read-only badge.
DataTableColumn<T> crudStatusColumn<T>({
  required AppKey labelKey,
  required Permission permission,
  required bool Function(T row) isActive,
  required ValueChanged<T> onToggleStatus,
  required Widget Function(BuildContext context, T row) badgeBuilder,
  required AppKey activateLabelKey,
  required AppKey deactivateLabelKey,
  String? sortKey,
  DataTableColumnPriority priority = DataTableColumnPriority.secondary,
}) => DataTableColumn<T>(
  labelKey: labelKey,
  sortKey: sortKey,
  priority: priority,
  cellBuilder: (context, row) => PermissionGate(
    permission: permission,
    fallback: badgeBuilder(context, row),
    child: AppSwitch(
      value: isActive(row),
      semanticsKey: isActive(row) ? deactivateLabelKey : activateLabelKey,
      onChanged: (_) => onToggleStatus(row),
    ),
  ),
);
