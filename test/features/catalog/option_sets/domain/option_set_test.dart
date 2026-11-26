import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/entity/option_set.dart';

void main() {
  OptionSet buildSet({
    required List<CatalogOption> options,
    required int? usage,
  }) => OptionSet(
    id: 1,
    name: 'Size',
    code: 'SIZE',
    selectionType: OptionSelectionType.single,
    isActive: true,
    options: options,
    usageCount: usage,
  );

  test('group deletion requires no options and known zero usage', () {
    expect(buildSet(options: const [], usage: 0).canDelete, isTrue);
    expect(buildSet(options: const [], usage: null).canDelete, isFalse);
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
      ).canDelete,
      isFalse,
    );
  });

  test('selection type is immutable when usage is present or unknown', () {
    expect(
      buildSet(options: const [], usage: 2).canChangeSelectionType,
      isFalse,
    );
    expect(
      buildSet(options: const [], usage: null).canChangeSelectionType,
      isFalse,
    );
    expect(
      buildSet(options: const [], usage: 0).canChangeSelectionType,
      isTrue,
    );
  });
}
