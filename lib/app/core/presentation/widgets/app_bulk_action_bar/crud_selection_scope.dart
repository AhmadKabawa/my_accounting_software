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
    this.selectionModeActive = false,
    this.onSelectionModeExit,
    required this.actionsBuilder,
    required this.builder,
  });

  final List<T> rows;
  final Object Function(T row) rowId;
  final ListSelectionCubit<Object> selection;
  final Permission permission;
  final bool selectionModeActive;
  final VoidCallback? onSelectionModeExit;
  final List<BulkAction> Function(List<T> selected) actionsBuilder;
  final Widget Function(
    BuildContext context,
    Set<Object> selectedIds,
    ValueChanged<Set<Object>>? onSelectionChanged,
  )
  builder;

  @override
  Widget build(BuildContext context) => BlocListener<AccessCubit, AccessState>(
    listener: (context, accessState) {
      final permitted =
          accessState.isReady &&
          accessState.snapshot!.permissions.any(
            (granted) => granted.covers(permission),
          );
      if (!permitted && selectionModeActive) {
        onSelectionModeExit?.call();
      }
    },
    child: BlocBuilder<ListSelectionCubit<Object>, Set<Object>>(
      bloc: selection,
      builder: (context, selectedIds) {
        final canBulk = context.watch<AccessCubit>().can(permission);
        final active = canBulk && selectionModeActive;
        final selected = rows
            .where((row) => selectedIds.contains(rowId(row)))
            .toList(growable: false);
        final pageIds = rows.map(rowId).toSet();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (active) ...[
              BulkActionBar(
                selectedCount: selected.length,
                onClear: onSelectionModeExit ?? selection.clear,
                actions: actionsBuilder(selected),
                pageSelectionState: selection.pageState(pageIds),
                onSelectPage: (select) {
                  if (select) {
                    selection.selectPage(pageIds);
                  } else {
                    selection.replace(selectedIds.difference(pageIds));
                  }
                },
              ),
              context.ui.spacing.gap(AppSpacing.sm),
            ],
            builder(
              context,
              active ? selectedIds : const <Object>{},
              active ? selection.replace : null,
            ),
          ],
        );
      },
    ),
  );
}
