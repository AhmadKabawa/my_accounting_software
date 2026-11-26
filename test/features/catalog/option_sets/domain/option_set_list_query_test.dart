import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/entity/option_set_list_query.dart';

void main() {
  test('option set query resets page and clears filters', () {
    const query = OptionSetListQuery(search: 'size', status: OptionSetStatusFilter.inactive, page: 4);
    expect(query.withSearch('color').page, 1);
    final cleared = query.cleared();
    expect(cleared.search, isEmpty);
    expect(cleared.status, OptionSetStatusFilter.all);
    expect(cleared.page, 1);
  });
}
