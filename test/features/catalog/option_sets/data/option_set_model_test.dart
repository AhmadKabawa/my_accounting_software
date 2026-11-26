import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/features/catalog/option_sets/data/models/option_set_model.dart';

void main() {
  Map<String, dynamic> json({
    Object? options = const [{'count': 4}],
    Object? attributes = const [{'count': 2}],
    Object? links = const [{'count': 1}],
  }) => {
    'id': 9,
    'name': 'Colours',
    'code': 'COL',
    'selection_type': 'multiple',
    'is_active': true,
    'options': options,
    'attributes': attributes,
    'product_type_option_sets': links,
  };

  test('parses count projections without embedding option rows', () {
    final model = OptionSetModel.fromJson(json());
    final set = model.toEntity();
    expect(model.optionCount, 4);
    expect(model.options, isEmpty);
    expect(set.optionCount, 4);
    expect(set.usageCount, 3);
    expect(set.canDelete, isFalse);
    expect(set.canChangeSelectionType, isFalse);
  });

  test('unknown counts block delete and selection type changes', () {
    final set = OptionSetModel.fromJson(
      json(options: null, attributes: null),
    ).toEntity();
    expect(set.optionCount, isNull);
    expect(set.usageCount, isNull);
    expect(set.canDelete, isFalse);
    expect(set.canChangeSelectionType, isFalse);
  });

  test('known zero counts allow deletion', () {
    final set = OptionSetModel.fromJson(
      json(
        options: const [{'count': 0}],
        attributes: const [{'count': 0}],
        links: const [{'count': 0}],
      ),
    ).toEntity();
    expect(set.canDelete, isTrue);
    expect(set.canChangeSelectionType, isTrue);
  });
}
