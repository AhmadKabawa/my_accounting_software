import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/localization/keys/catalog_ui_keys.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/foundation/types/bulk_result.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';

/// Shared, count-aware report for partial and complete bulk failures.
abstract final class BulkResultDialog {
  static Future<void> show<T>(
    BuildContext context,
    BulkResult<T> result, {
    required String Function(T item) itemLabel,
  }) async {
    if (result.failureCount == 0 || !context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        insetPadding: EdgeInsets.all(dialogContext.ui.spacing.lg),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: AppComponentSize.formDialogWidth.of(dialogContext),
            maxHeight: MediaQuery.sizeOf(dialogContext).height -
                dialogContext.ui.spacing.lg * 2,
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(dialogContext.ui.spacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppText(
                  CatalogUiKeys.bulkResultTitle,
                  type: AppTextType.titleLarge,
                ),
                dialogContext.ui.spacing.gap(AppSpacing.md),
                AppText.raw(CatalogUiKeys.bulkResultSummary.tr(
                  context: dialogContext,
                  namedArgs: {
                    'success': result.successCount.toString(),
                    'failure': result.failureCount.toString(),
                  },
                )),
                for (final failure in result.failures)
                  Padding(
                    padding: EdgeInsets.only(top: dialogContext.ui.spacing.xs),
                    child: AppText.raw(CatalogUiKeys.bulkFailureLine.tr(
                      context: dialogContext,
                      namedArgs: {
                        'name': itemLabel(failure.item),
                        'reason': failure.reason.messageKey.tr(context: dialogContext),
                      },
                    )),
                  ),
                dialogContext.ui.spacing.gap(AppSpacing.lg),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: AppButton(
                    CatalogUiKeys.done,
                    onPressed: () => Navigator.of(dialogContext).pop(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
