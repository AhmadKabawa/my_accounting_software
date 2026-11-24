import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_actions_config.dart';

void main() {
  group('CrudActionsConfig', () {
    testWidgets('dispatches each feature-owned action with context and row', (
      tester,
    ) async {
      final calls = <String>[];
      const row = 42;
      final config = CrudActionsConfig<int>(
        onEdit: (_, item) => calls.add('edit:$item'),
        onDuplicate: (_, item) => calls.add('duplicate:$item'),
        onDelete: (_, item) => calls.add('delete:$item'),
        onToggleStatus: (_, item) => calls.add('status:$item'),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              CrudListActions.edit(context, config, row);
              CrudListActions.duplicate(context, config, row);
              CrudListActions.delete(context, config, row);
              CrudListActions.toggleStatus(context, config, row);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(calls, ['edit:42', 'duplicate:42', 'delete:42', 'status:42']);
    });

    testWidgets('does nothing when an optional action is not configured', (
      tester,
    ) async {
      const config = CrudActionsConfig<int>();
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              CrudListActions.edit(context, config, 1);
              CrudListActions.duplicate(context, config, 1);
              CrudListActions.delete(context, config, 1);
              CrudListActions.toggleStatus(context, config, 1);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });
}
