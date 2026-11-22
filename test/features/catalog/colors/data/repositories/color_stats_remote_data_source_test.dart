import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/entity/color_stats.dart';
import 'package:accounting_software/app/features/catalog/colors/data/datasources/color_stats_remote_data_source_impl.dart';
import '../../support/fake_colors_api_client.dart';

void main() {
  test('maps total and active count responses to inactive remainder', () async {
    final api = FakeColorsApiClient()
      ..totalCount = 8
      ..activeCount = 5;
    final source = ColorStatsRemoteDataSourceImpl(api);

    final result = await source.getColorStats();

    expect(result, isA<ApiSuccess<ColorStats>>());
    result.when(
      success: (stats) {
        expect(stats.total, 8);
        expect(stats.active, 5);
        expect(stats.inactive, 3);
      },
      failure: (_) => fail('Expected statistics'),
    );
    expect(api.paginatedQueries, hasLength(2));
    expect(api.paginatedQueries[0], {'select': 'id'});
    expect(api.paginatedQueries[1], {
      'select': 'id',
      'is_active': 'eq.true',
    });
  });
}
