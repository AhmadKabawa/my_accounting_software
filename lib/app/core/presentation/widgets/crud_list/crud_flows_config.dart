import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_confirm_dialog/crud_confirmations.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_actions_config.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_labels.dart';

/// Shared edit, duplicate, delete and status flows with feature-owned policy.
class CrudFlowsConfig<T, C> {
  const CrudFlowsConfig({
    required this.showEditor,
    required this.onSaved,
    required this.itemLabel,
    required this.delete,
    required this.activate,
    required this.deactivate,
    this.labels,
    @Deprecated('Use labels.') AppKey? deleteTitleKey,
    @Deprecated('Use labels.') AppKey? deleteMessageKey,
    @Deprecated('Use labels.') AppKey? deactivateTitleKey,
    @Deprecated('Use labels.') AppKey? deactivateMessageKey,
    @Deprecated('Use labels.') AppKey? editLabelKey,
    @Deprecated('Use labels.') AppKey? deleteLabelKey,
    @Deprecated('Use labels.') AppKey? duplicateLabelKey,
    @Deprecated('Use labels.') AppKey? activateLabelKey,
    @Deprecated('Use labels.') AppKey? deactivateLabelKey,
    required this.isActive,
    this.canDelete,
    this.messageArgs,
  }) : _deleteTitleKey = deleteTitleKey,
       _deleteMessageKey = deleteMessageKey,
       _deactivateTitleKey = deactivateTitleKey,
       _deactivateMessageKey = deactivateMessageKey,
       _editLabelKey = editLabelKey,
       _deleteLabelKey = deleteLabelKey,
       _duplicateLabelKey = duplicateLabelKey,
       _activateLabelKey = activateLabelKey,
       _deactivateLabelKey = deactivateLabelKey;

  final Future<bool?> Function(BuildContext context, {T? item, bool duplicate})
  showEditor;
  final Future<void> Function(C cubit, {required bool isNew}) onSaved;
  final String Function(T item) itemLabel;
  final Future<Either<Failure, Unit>> Function(C cubit, T item) delete;
  final Future<Either<Failure, Unit>> Function(C cubit, T item) activate;
  final Future<Either<Failure, Unit>> Function(C cubit, T item) deactivate;
  final CrudLabels? labels;
  final AppKey? _deleteTitleKey;
  final AppKey? _deleteMessageKey;
  final AppKey? _deactivateTitleKey;
  final AppKey? _deactivateMessageKey;
  final AppKey? _editLabelKey;
  final AppKey? _deleteLabelKey;
  final AppKey? _duplicateLabelKey;
  final AppKey? _activateLabelKey;
  final AppKey? _deactivateLabelKey;

  AppKey get deleteTitleKey => labels?.deleteConfirmationTitle ?? _deleteTitleKey!;
  AppKey get deleteMessageKey => labels?.deleteConfirmationMessage ?? _deleteMessageKey!;
  AppKey get deactivateTitleKey => labels?.deactivateConfirmationTitle ?? _deactivateTitleKey!;
  AppKey get deactivateMessageKey => labels?.deactivateConfirmationMessage ?? _deactivateMessageKey!;
  AppKey get editLabelKey => labels?.edit ?? _editLabelKey!;
  AppKey get deleteLabelKey => labels?.delete ?? _deleteLabelKey!;
  AppKey get duplicateLabelKey => labels?.duplicate ?? _duplicateLabelKey!;
  AppKey get activateLabelKey => labels?.activate ?? _activateLabelKey!;
  AppKey get deactivateLabelKey => labels?.deactivate ?? _deactivateLabelKey!;
  final bool Function(T item) isActive;
  final bool Function(T item)? canDelete;
  final Map<String, String> Function(T item)? messageArgs;

  @Deprecated('Legacy test adapter; production lists use flows directly.')
  CrudActionsConfig<T> buildActions() => CrudActionsConfig<T>(
    onEdit: (context, item) => edit(context, item: item),
    onDuplicate: (context, item) => edit(context, item: item, duplicate: true),
    onDelete: deleteItem,
    onToggleStatus: toggleStatus,
  );

  void add(BuildContext context) {
    edit(context);
  }

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
      messageArgs: messageArgs?.call(item),
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
