import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/entity/catalog_attribute.dart';

void main() {
  CatalogAttribute buildAttribute({
    required int? links,
    required int? values,
  }) => CatalogAttribute(
    id: 1,
    name: 'Material',
    code: 'MATERIAL',
    dataType: AttributeDataType.text,
    unitId: null,
    unitName: null,
    unitSymbol: null,
    optionSetId: null,
    optionSetName: null,
    optionSetCode: null,
    isFilterable: true,
    isActive: true,
    linkedProductTypesCount: links,
    valueCount: values,
  );

  test('unknown usage is treated as in-use', () {
    expect(buildAttribute(links: null, values: 0).canDelete, isFalse);
    expect(buildAttribute(links: 0, values: null).canDelete, isFalse);
    expect(buildAttribute(links: 0, values: 0).canDelete, isTrue);
    expect(buildAttribute(links: 1, values: 0).canChangeType, isFalse);
  });
}
