import 'package:accounting_software/app/core/localization/translations/app_key.dart';

/// One localized vocabulary shared by CRUD row flows and data presentation.
///
/// Bulk-operation labels remain in [CrudBulkConfig] because they describe a
/// separate, count-aware operation set.
class CrudLabels {
  const CrudLabels({
    required this.edit,
    required this.delete,
    required this.duplicate,
    required this.activate,
    required this.deactivate,
    required this.deleteConfirmationTitle,
    required this.deleteConfirmationMessage,
    required this.deactivateConfirmationTitle,
    required this.deactivateConfirmationMessage,
  });

  final AppKey edit;
  final AppKey delete;
  final AppKey duplicate;
  final AppKey activate;
  final AppKey deactivate;
  final AppKey deleteConfirmationTitle;
  final AppKey deleteConfirmationMessage;
  final AppKey deactivateConfirmationTitle;
  final AppKey deactivateConfirmationMessage;
}
