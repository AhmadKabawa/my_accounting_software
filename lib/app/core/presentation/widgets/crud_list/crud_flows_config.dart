import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_confirm_dialog/crud_confirmations.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_labels.dart';

/// Shared edit, duplicate, delete and status flows with feature-owned policy.
///
/// Delete and status are optional: leave [delete], or [activate], [deactivate]
/// and [isActive], null (with the matching [CrudLabels] groups) for an entity
/// that cannot be deleted or has no `is_active`.
class CrudFlowsConfig<T, C> {
  const CrudFlowsConfig({
    required this.showEditor,
    required this.onSaved,
    required this.itemLabel,
    required this.labels,
    this.delete,
    this.activate,
    this.deactivate,
    this.isActive,
    this.canDelete,
    this.messageArgs,
  });

  final Future<bool?> Function(BuildContext context, {T? item, bool duplicate})
  showEditor;
  final Future<void> Function(C cubit, {required bool isNew}) onSaved;
  final String Function(T item) itemLabel;
  final CrudLabels labels;
  final Future<Either<Failure, Unit>> Function(C cubit, T item)? delete;
  final Future<Either<Failure, Unit>> Function(C cubit, T item)? activate;
  final Future<Either<Failure, Unit>> Function(C cubit, T item)? deactivate;
  final bool Function(T item)? isActive;

  /// Per-row policy: false keeps the Delete menu item visible but disabled.
  final bool Function(T item)? canDelete;
  final Map<String, String> Function(T item)? messageArgs;

  /// Rows can be deleted: the callback and the label group are both present.
  bool get hasDelete => delete != null && labels.supportsDelete;

  /// Rows have a status: all three callbacks and the label group are present.
  bool get hasStatus =>
      isActive != null &&
      activate != null &&
      deactivate != null &&
      labels.supportsStatus;

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
    final remove = delete;
    final title = labels.deleteConfirmationTitle;
    final message = labels.deleteConfirmationMessage;
    if (remove == null || title == null || message == null) {
      return Future<void>.value();
    }
    final cubit = context.read<C>();
    return CrudConfirmations.delete(
      context,
      titleKey: title,
      messageKey: message,
      messageArgs: messageArgs?.call(item),
      targetName: itemLabel(item),
      onDelete: () => remove(cubit, item),
    );
  }

  Future<void> toggleStatus(BuildContext context, T item) {
    final active = isActive;
    final enable = activate;
    final disable = deactivate;
    final title = labels.deactivateConfirmationTitle;
    final message = labels.deactivateConfirmationMessage;
    if (active == null ||
        enable == null ||
        disable == null ||
        title == null ||
        message == null) {
      return Future<void>.value();
    }
    final cubit = context.read<C>();
    return CrudConfirmations.status(
      context,
      isActive: active(item),
      targetName: itemLabel(item),
      titleKey: title,
      messageKey: message,
      onActivate: () => enable(cubit, item),
      onDeactivate: () => disable(cubit, item),
    );
  }
}
