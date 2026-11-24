import 'package:flutter/foundation.dart';

/// Feature-owned record operations supplied to the shared CRUD list engine.
///
/// The callbacks retain each feature's existing editor, confirmation,
/// permission and mutation behavior; Core only dispatches the selected action.
class CrudActionsConfig<T> {
  const CrudActionsConfig({
    this.onEdit,
    this.onDuplicate,
    this.onDelete,
    this.onToggleStatus,
  });

  final ValueChanged<T>? onEdit;
  final ValueChanged<T>? onDuplicate;
  final ValueChanged<T>? onDelete;
  final ValueChanged<T>? onToggleStatus;
}

/// Typed dispatch helpers shared by feature-owned row presentations.
abstract final class CrudListActions {
  static void edit<T>(CrudActionsConfig<T> config, T item) {
    config.onEdit?.call(item);
  }

  static void duplicate<T>(CrudActionsConfig<T> config, T item) {
    config.onDuplicate?.call(item);
  }

  static void delete<T>(CrudActionsConfig<T> config, T item) {
    config.onDelete?.call(item);
  }

  static void toggleStatus<T>(CrudActionsConfig<T> config, T item) {
    config.onToggleStatus?.call(item);
  }
}
