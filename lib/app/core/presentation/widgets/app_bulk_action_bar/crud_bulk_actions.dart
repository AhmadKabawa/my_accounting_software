import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/access/permission.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_bulk_action_bar/bulk_action_bar.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_confirm_dialog/confirm_dialog.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';

/// Standard activate/deactivate/delete actions for CRUD lists.
abstract final class CrudBulkActions {
  static List<BulkAction> statusAndDelete({
    required Permission permission,
    required AppKey activateLabelKey,
    required AppKey deactivateLabelKey,
    required AppKey deleteLabelKey,
    required AppKey deactivateTitleKey,
    required AppKey deactivateMessageKey,
    required AppKey deleteTitleKey,
    required AppKey deleteMessageKey,
    required Future<void> Function() onActivate,
    required Future<void> Function() onDeactivate,
    required Future<void> Function() onDelete,
  }) => [
    BulkAction(
      labelKey: activateLabelKey,
      icon: AppIcons.refresh,
      permission: permission,
      onRun: onActivate,
    ),
    BulkAction(
      labelKey: deactivateLabelKey,
      icon: AppIcons.refresh,
      permission: permission,
      confirm: (context, count) => showConfirmDialog(
        context,
        titleKey: deactivateTitleKey,
        messageKey: deactivateMessageKey,
        messageArgs: {'count': count.toString()},
        severity: ConfirmDialogSeverity.warning,
      ),
      onRun: onDeactivate,
    ),
    BulkAction(
      labelKey: deleteLabelKey,
      icon: AppIcons.delete,
      permission: permission,
      destructive: true,
      confirm: (context, count) => showConfirmDialog(
        context,
        titleKey: deleteTitleKey,
        messageKey: deleteMessageKey,
        messageArgs: {'count': count.toString()},
        severity: ConfirmDialogSeverity.critical,
      ),
      onRun: onDelete,
    ),
  ];
}
