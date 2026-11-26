import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/entity/attribute_list_query.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/entity/catalog_attribute.dart';

void main() {
  test('attribute query tracks every non-default filter', () {
    const query = AttributeListQuery(
      dataType: AttributeDataType.number,
      filterable: AttributeFilterableFilter.filterable,
      page: 5,
    );
    expect(query.hasActiveFilters, isTrue);
    expect(query.withSearch('width').page, 1);
    final cleared = query.cleared();
    expect(cleared.dataType, isNull);
    expect(cleared.filterable, AttributeFilterableFilter.all);
    expect(cleared.status, AttributeStatusFilter.all);
  });
}
