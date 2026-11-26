import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/entity/option_set.dart';

void main() {
  OptionSet buildSet({
    required List<CatalogOption> options,
    required int? usage,
    required int? optionCount,
  }) => OptionSet(
    id: 1,
    name: 'Size',
    code: 'SIZE',
    selectionType: OptionSelectionType.single,
    isActive: true,
    options: options,
    usageCount: usage,
    optionCount: optionCount,
  );

  test('group deletion requires no options and known zero usage', () {
    expect(buildSet(options: const [], usage: 0, optionCount: 0).canDelete, isTrue);
    expect(buildSet(options: const [], usage: null, optionCount: 0).canDelete, isFalse);
    expect(
      buildSet(
        options: const [
          CatalogOption(
            id: 1,
            name: 'Small',
            code: 'S',
            sortOrder: 1,
            isActive: true,
          ),
        ],
        usage: 0,
        optionCount: 1,
      ).canDelete,
      isFalse,
    );
  });

  test('unknown option count blocks deletion even with zero known usage', () {
    expect(
      buildSet(options: const [], usage: 0, optionCount: null).canDelete,
      isFalse,
    );
  });

  test('selection type is immutable when usage is present or unknown', () {
    expect(
      buildSet(options: const [], usage: 2, optionCount: 0).canChangeSelectionType,
      isFalse,
    );
    expect(
      buildSet(options: const [], usage: null, optionCount: 0).canChangeSelectionType,
      isFalse,
    );
    expect(
      buildSet(options: const [], usage: 0, optionCount: 0).canChangeSelectionType,
      isTrue,
    );
  });
}
