import 'package:accounting_software/app/core/foundation/types/bulk_result.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';

/// Feature policy and localized copy for the standard bulk CRUD actions.
class CrudBulkConfig<T, C> {
  const CrudBulkConfig({
    required this.activateLabelKey,
    required this.deactivateLabelKey,
    required this.deleteLabelKey,
    required this.deactivateTitleKey,
    required this.deactivateMessageKey,
    required this.deleteTitleKey,
    required this.deleteMessageKey,
    required this.activate,
    required this.deactivate,
    required this.delete,
  });

  final AppKey activateLabelKey;
  final AppKey deactivateLabelKey;
  final AppKey deleteLabelKey;
  final AppKey deactivateTitleKey;
  final AppKey deactivateMessageKey;
  final AppKey deleteTitleKey;
  final AppKey deleteMessageKey;
  final Future<BulkResult<T>> Function(C cubit, List<T> selected) activate;
  final Future<BulkResult<T>> Function(C cubit, List<T> selected) deactivate;
  final Future<BulkResult<T>> Function(C cubit, List<T> selected) delete;
}
