import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/entity/color_list_query.dart';

void main() {
  test('withSorts retains every distinct criterion in priority order', () {
    const expected = [
      ColorSort(ColorSortField.code, false),
      ColorSort(ColorSortField.order, true),
      ColorSort(ColorSortField.name, false),
    ];
    final query = const ColorListQuery().withSorts(expected);
    expect(query.sorts, expected);
  });
}
