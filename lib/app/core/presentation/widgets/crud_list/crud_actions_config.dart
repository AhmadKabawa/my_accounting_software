import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_row_actions/app_row_actions.dart';

/// Feature-owned record operations supplied to the shared CRUD list engine.
///
/// The callbacks retain each feature's existing editor, confirmation,
/// permission and mutation behavior; Core only dispatches the selected action.
@Deprecated('Use CrudFlowsConfig; retained only for legacy unit tests.')
class CrudActionsConfig<T> {
  const CrudActionsConfig({
    this.onEdit,
    this.onDuplicate,
    this.onDelete,
    this.onToggleStatus,
    this.extraRowActions,
  });

  final void Function(BuildContext context, T item)? onEdit;
  final void Function(BuildContext context, T item)? onDuplicate;
  final void Function(BuildContext context, T item)? onDelete;
  final void Function(BuildContext context, T item)? onToggleStatus;
  final List<AppRowAction> Function(BuildContext context, T item)?
  extraRowActions;

  CrudActionsConfig<T> withoutDuplicate() => CrudActionsConfig<T>(
    onEdit: onEdit,
    onDelete: onDelete,
    onToggleStatus: onToggleStatus,
    extraRowActions: extraRowActions,
  );
}

/// Typed dispatch helpers shared by feature-owned row presentations.
@Deprecated('Use CrudFlowsConfig methods directly.')
abstract final class CrudListActions {
  static void edit<T>(
    BuildContext context,
    CrudActionsConfig<T> config,
    T item,
  ) {
    config.onEdit?.call(context, item);
  }

  static void duplicate<T>(
    BuildContext context,
    CrudActionsConfig<T> config,
    T item,
  ) {
    config.onDuplicate?.call(context, item);
  }

  static void delete<T>(
    BuildContext context,
    CrudActionsConfig<T> config,
    T item,
  ) {
    config.onDelete?.call(context, item);
  }

  static void toggleStatus<T>(
    BuildContext context,
    CrudActionsConfig<T> config,
    T item,
  ) {
    config.onToggleStatus?.call(context, item);
  }
}
