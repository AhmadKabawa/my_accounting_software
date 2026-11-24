import 'package:accounting_software/app/core/foundation/types/bulk_result.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';

/// Feature policy and localized copy for the standard bulk CRUD actions.
///
/// Each operation is optional: omit an operation's callback and copy to leave
/// it out of the bulk bar (for example activate/deactivate for an entity
/// without `is_active`). An operation shows only when its callback and every
/// key it needs are present.
class CrudBulkConfig<T, C> {
  const CrudBulkConfig({
    this.activateLabelKey,
    this.deactivateLabelKey,
    this.deleteLabelKey,
    this.deactivateTitleKey,
    this.deactivateMessageKey,
    this.deleteTitleKey,
    this.deleteMessageKey,
    this.activate,
    this.deactivate,
    this.delete,
  });

  final AppKey? activateLabelKey;
  final AppKey? deactivateLabelKey;
  final AppKey? deleteLabelKey;
  final AppKey? deactivateTitleKey;
  final AppKey? deactivateMessageKey;
  final AppKey? deleteTitleKey;
  final AppKey? deleteMessageKey;
  final Future<BulkResult<T>> Function(C cubit, List<T> selected)? activate;
  final Future<BulkResult<T>> Function(C cubit, List<T> selected)? deactivate;
  final Future<BulkResult<T>> Function(C cubit, List<T> selected)? delete;
}
