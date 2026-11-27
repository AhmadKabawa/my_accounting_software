import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_confirm_dialog/confirm_dialog.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/entity/catalog_attribute.dart';
import 'package:accounting_software/app/features/catalog/attributes/presentation/cubit/attributes_list/attributes_list_cubit.dart';
import 'package:accounting_software/app/features/catalog/attributes/presentation/localization/attributes_keys.dart';

Future<void> confirmDeleteAttribute(
  BuildContext context,
  CatalogAttribute item,
) async {
  var used = false;
  final cubit = context.read<AttributesListCubit>();
  final confirmed = await showConfirmDialog(
    context,
    titleKey: AttributesKeys.delete,
    messageKey: AttributesKeys.confirmDelete,
    targetName: item.name,
    severity: ConfirmDialogSeverity.critical,
    onConfirm: () async {
      final result = await cubit.delete(item);
      return result.fold((failure) {
        if (failure.messageKey == AttributesKeys.inUse) {
          used = true;
          return null;
        }
        return failure.messageKey;
      }, (_) => null);
    },
  );
  if (!confirmed || !used || !context.mounted) return;
  await showConfirmDialog(
    context,
    titleKey: AttributesKeys.deactivateInstead,
    messageKey: AttributesKeys.confirmDeactivate,
    targetName: item.name,
    severity: ConfirmDialogSeverity.warning,
    confirmLabelKey: AttributesKeys.deactivate,
    onConfirm: () async => (await cubit.deactivate(
      item.id,
    )).fold((failure) => failure.messageKey, (_) => null),
  );
}

