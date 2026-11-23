import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/core/access/cubit/access_cubit.dart';
import 'package:accounting_software/app/core/access/permission.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/state_management/list_selection_cubit.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_bulk_action_bar/bulk_action_bar.dart';

/// Shares page selection, server-authoritative permission and bulk actions
/// across CRUD list features without embedding feature permissions in Core.
class CrudSelectionScope<T> extends StatelessWidget {
  const CrudSelectionScope({
    super.key,
    required this.rows,
    required this.rowId,
    required this.selection,
    required this.permission,
    required this.actionsBuilder,
    required this.builder,
  });

  final List<T> rows;
  final Object Function(T row) rowId;
  final ListSelectionCubit<Object> selection;
  final Permission permission;
  final List<BulkAction> Function(List<T> selected) actionsBuilder;
  final Widget Function(
    BuildContext context,
    Set<Object> selectedIds,
    ValueChanged<Set<Object>>? onSelectionChanged,
  )
  builder;

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<ListSelectionCubit<Object>, Set<Object>>(
        bloc: selection,
        builder: (context, selectedIds) {
          final canBulk = context.watch<AccessCubit>().can(permission);
          final selected = rows
              .where((row) => selectedIds.contains(rowId(row)))
              .toList(growable: false);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (canBulk && selected.isNotEmpty) ...[
                BulkActionBar(
                  selectedCount: selected.length,
                  onClear: selection.clear,
                  actions: actionsBuilder(selected),
                ),
                context.ui.spacing.gap(AppSpacing.sm),
              ],
              builder(
                context,
                canBulk ? selectedIds : const <Object>{},
                canBulk ? selection.replace : null,
              ),
            ],
          );
        },
      );
}
