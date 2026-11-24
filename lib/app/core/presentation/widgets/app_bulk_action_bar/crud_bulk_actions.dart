import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/access/permission.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/foundation/types/bulk_result.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_bulk_action_bar/bulk_action_bar.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_bulk_action_bar/bulk_result_dialog.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_confirm_dialog/confirm_dialog.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';

/// Standard activate/deactivate/delete actions for CRUD lists.
///
/// Every operation is optional: pass null callbacks and keys for one an entity
/// does not have (for example no activate/deactivate without `is_active`).
abstract final class CrudBulkActions {
  static List<BulkAction> statusAndDelete<T>({
    required BuildContext context,
    required Permission permission,
    required List<T> selected,
    required String Function(T item) itemLabel,
    AppKey? activateLabelKey,
    AppKey? deactivateLabelKey,
    AppKey? deleteLabelKey,
    AppKey? deactivateTitleKey,
    AppKey? deactivateMessageKey,
    AppKey? deleteTitleKey,
    AppKey? deleteMessageKey,
    Future<BulkResult<T>> Function(List<T> selected)? onActivate,
    Future<BulkResult<T>> Function(List<T> selected)? onDeactivate,
    Future<BulkResult<T>> Function(List<T> selected)? onDelete,
  }) {
    final navigator = Navigator.of(context, rootNavigator: true);
    Future<void> report(Future<BulkResult<T>> Function(List<T>) action) async {
      final result = await action(selected);
      if (!navigator.mounted) return;
      await BulkResultDialog.show(
        navigator.context,
        result,
        itemLabel: itemLabel,
      );
    }

    return [
      if (onActivate != null && activateLabelKey != null)
        BulkAction(
          labelKey: activateLabelKey,
          icon: AppIcons.restore,
          permission: permission,
          onRun: () => report(onActivate),
        ),
      if (onDeactivate != null &&
          deactivateLabelKey != null &&
          deactivateTitleKey != null &&
          deactivateMessageKey != null)
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
      if (onDelete != null &&
          deleteLabelKey != null &&
          deleteTitleKey != null &&
          deleteMessageKey != null)
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
