import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_actions_config.dart';

void main() {
  group('CrudActionsConfig', () {
    test('dispatches each feature-owned action with its row', () {
      final calls = <String>[];
      const row = 42;
      final config = CrudActionsConfig<int>(
        onEdit: (item) => calls.add('edit:$item'),
        onDuplicate: (item) => calls.add('duplicate:$item'),
        onDelete: (item) => calls.add('delete:$item'),
        onToggleStatus: (item) => calls.add('status:$item'),
      );

      CrudListActions.edit(config, row);
      CrudListActions.duplicate(config, row);
      CrudListActions.delete(config, row);
      CrudListActions.toggleStatus(config, row);

      expect(calls, ['edit:42', 'duplicate:42', 'delete:42', 'status:42']);
    });

    test('does nothing when an optional action is not configured', () {
      const config = CrudActionsConfig<int>();

      expect(() => CrudListActions.edit(config, 1), returnsNormally);
      expect(() => CrudListActions.duplicate(config, 1), returnsNormally);
      expect(() => CrudListActions.delete(config, 1), returnsNormally);
      expect(() => CrudListActions.toggleStatus(config, 1), returnsNormally);
    });
  });
}
