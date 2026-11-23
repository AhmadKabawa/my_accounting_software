import 'package:flutter/material.dart';
import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_confirm_dialog/confirm_dialog.dart';

/// Common confirmation flows for CRUD records; feature Cubits provide actions.
abstract final class CrudConfirmations {
  static Future<bool> delete(
    BuildContext context, {
    required AppKey titleKey,
    required AppKey messageKey,
    Map<String, String>? messageArgs,
    required String targetName,
    required Future<Either<Failure, Unit>> Function() onDelete,
  }) => showConfirmDialog(
    context,
    titleKey: titleKey,
    messageKey: messageKey,
    messageArgs: messageArgs,
    targetName: targetName,
    severity: ConfirmDialogSeverity.critical,
    onConfirm: () async =>
        (await onDelete()).fold((failure) => failure.messageKey, (_) => null),
  );

  /// Activating is immediate; deactivating is confirmed because it changes
  /// availability for users of the record.
  static Future<void> status(
    BuildContext context, {
    required bool isActive,
    required String targetName,
    required AppKey titleKey,
    required AppKey messageKey,
    required Future<void> Function() onActivate,
    required Future<Either<Failure, Unit>> Function() onDeactivate,
  }) async {
    if (!isActive) {
      await onActivate();
      return;
    }
    await showConfirmDialog(
      context,
      titleKey: titleKey,
      messageKey: messageKey,
      targetName: targetName,
      severity: ConfirmDialogSeverity.warning,
      onConfirm: () async => (await onDeactivate())
          .fold((failure) => failure.messageKey, (_) => null),
    );
  }
}
