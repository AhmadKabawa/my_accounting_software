import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/presentation/state_management/list_selection_cubit.dart';
void main() {
  test('toggle, select page, replace and clear keep only selected IDs', () async {
    final cubit = ListSelectionCubit<int>();
    expect(cubit.count, 0);
    expect(cubit.pageState([1, 2]), PageSelectionState.none);
    cubit.toggle(1);
    expect(cubit.isSelected(1), isTrue);
    expect(cubit.pageState([1, 2]), PageSelectionState.partial);
    cubit.selectPage([1, 2, 3]);
    expect(cubit.count, 3);
    expect(cubit.pageState([1, 2, 3]), PageSelectionState.all);
    cubit.toggle(2);
    expect(cubit.pageState([1, 2, 3]), PageSelectionState.partial);
    cubit.replace({7, 8});
    expect(cubit.state, {7, 8});
    cubit.clear();
    expect(cubit.count, 0);
    expect(cubit.pageState([7, 8]), PageSelectionState.none);
    await cubit.close();
  });
}
