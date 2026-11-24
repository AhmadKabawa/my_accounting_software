import 'package:accounting_software/app/core/localization/translations/app_key.dart';

/// One localized vocabulary shared by CRUD row flows and data presentation.
///
/// Only [edit] is mandatory. Leave a group null when the entity does not have
/// that operation: no [delete] (row menu item and its confirmation), no
/// [duplicate], or no status (activate/deactivate and the deactivation
/// confirmation) for an entity without `is_active`.
///
/// Bulk-operation labels remain in [CrudBulkConfig] because they describe a
/// separate, count-aware operation set.
class CrudLabels {
  const CrudLabels({
    required this.edit,
    this.delete,
    this.duplicate,
    this.activate,
    this.deactivate,
    this.deleteConfirmationTitle,
    this.deleteConfirmationMessage,
    this.deactivateConfirmationTitle,
    this.deactivateConfirmationMessage,
  });

  final AppKey edit;
  final AppKey? delete;
  final AppKey? duplicate;
  final AppKey? activate;
  final AppKey? deactivate;
  final AppKey? deleteConfirmationTitle;
  final AppKey? deleteConfirmationMessage;
  final AppKey? deactivateConfirmationTitle;
  final AppKey? deactivateConfirmationMessage;

  /// The entity can be deleted: menu label and confirmation copy are present.
  bool get supportsDelete =>
      delete != null &&
      deleteConfirmationTitle != null &&
      deleteConfirmationMessage != null;

  /// The entity has a status: both labels and the deactivation copy exist.
  bool get supportsStatus =>
      activate != null &&
      deactivate != null &&
      deactivateConfirmationTitle != null &&
      deactivateConfirmationMessage != null;
}
