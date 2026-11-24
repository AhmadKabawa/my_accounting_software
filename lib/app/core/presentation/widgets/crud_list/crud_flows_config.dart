import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_confirm_dialog/crud_confirmations.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_actions_config.dart';

/// Shared edit, duplicate, delete and status flows with feature-owned policy.
class CrudFlowsConfig<T, C> {
  const CrudFlowsConfig({
    required this.showEditor,
    required this.onSaved,
    required this.itemLabel,
    required this.delete,
    required this.activate,
    required this.deactivate,
    required this.deleteTitleKey,
    required this.deleteMessageKey,
    required this.deactivateTitleKey,
    required this.deactivateMessageKey,
    required this.editLabelKey,
    required this.deleteLabelKey,
    required this.duplicateLabelKey,
    required this.activateLabelKey,
    required this.deactivateLabelKey,
    required this.isActive,
    this.canDelete,
  });

  final Future<bool?> Function(BuildContext context, {T? item, bool duplicate})
  showEditor;
  final Future<void> Function(C cubit, {required bool isNew}) onSaved;
  final String Function(T item) itemLabel;
  final Future<Either<Failure, Unit>> Function(C cubit, T item) delete;
  final Future<Either<Failure, Unit>> Function(C cubit, T item) activate;
  final Future<Either<Failure, Unit>> Function(C cubit, T item) deactivate;
  final AppKey deleteTitleKey;
  final AppKey deleteMessageKey;
  final AppKey deactivateTitleKey;
  final AppKey deactivateMessageKey;
  final AppKey editLabelKey;
  final AppKey deleteLabelKey;
  final AppKey duplicateLabelKey;
  final AppKey activateLabelKey;
  final AppKey deactivateLabelKey;
  final bool Function(T item) isActive;
  final bool Function(T item)? canDelete;

  void add(BuildContext context) {
    edit(context);
  }

  CrudActionsConfig<T> buildActions() => CrudActionsConfig<T>(
    onEdit: (context, item) => edit(context, item: item),
    onDuplicate: (context, item) => edit(context, item: item, duplicate: true),
    onDelete: deleteItem,
    onToggleStatus: toggleStatus,
  );

  Future<void> edit(
    BuildContext context, {
    T? item,
    bool duplicate = false,
  }) async {
    final saved = await showEditor(context, item: item, duplicate: duplicate);
    if (saved != true || !context.mounted) return;
    await onSaved(context.read<C>(), isNew: item == null || duplicate);
  }

  Future<void> deleteItem(BuildContext context, T item) {
    final cubit = context.read<C>();
    return CrudConfirmations.delete(
      context,
      titleKey: deleteTitleKey,
      messageKey: deleteMessageKey,
      targetName: itemLabel(item),
      onDelete: () => delete(cubit, item),
    );
  }

  Future<void> toggleStatus(BuildContext context, T item) {
    final cubit = context.read<C>();
    return CrudConfirmations.status(
      context,
      isActive: isActive(item),
      targetName: itemLabel(item),
      titleKey: deactivateTitleKey,
      messageKey: deactivateMessageKey,
      onActivate: () => activate(cubit, item),
      onDeactivate: () => deactivate(cubit, item),
    );
  }
}
