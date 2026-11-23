import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/access/permission.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/foundation/types/bulk_result.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_bulk_action_bar/bulk_action_bar.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_bulk_action_bar/bulk_result_dialog.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_confirm_dialog/confirm_dialog.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';

/// Standard activate/deactivate/delete actions for CRUD lists.
abstract final class CrudBulkActions {
  static List<BulkAction> statusAndDelete<T>({
    required BuildContext context,
    required Permission permission,
    required List<T> selected,
    required String Function(T item) itemLabel,
    required AppKey activateLabelKey,
    required AppKey deactivateLabelKey,
    required AppKey deleteLabelKey,
    required AppKey deactivateTitleKey,
    required AppKey deactivateMessageKey,
    required AppKey deleteTitleKey,
    required AppKey deleteMessageKey,
    required Future<BulkResult<T>> Function(List<T> selected) onActivate,
    required Future<BulkResult<T>> Function(List<T> selected) onDeactivate,
    required Future<BulkResult<T>> Function(List<T> selected) onDelete,
  }) {
    Future<void> report(Future<BulkResult<T>> Function(List<T>) action) async {
      final result = await action(selected);
      await BulkResultDialog.show(context, result, itemLabel: itemLabel);
    }

    return [
      BulkAction(
        labelKey: activateLabelKey,
        icon: AppIcons.restore,
        permission: permission,
        onRun: () => report(onActivate),
      ),
      BulkAction(
        labelKey: deactivateLabelKey,
        icon: AppIcons.block,
        permission: permission,
        confirm: (context, count) => showConfirmDialog(
          context,
          titleKey: deactivateTitleKey,
          messageKey: deactivateMessageKey,
          messageArgs: {'count': count.toString()},
          severity: ConfirmDialogSeverity.warning,
        ),
        onRun: () => report(onDeactivate),
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
        onRun: () => report(onDelete),
      ),
    ];
  }
}
