import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/features/catalog/colors/data/colors_endpoint.dart';
import 'package:accounting_software/app/features/catalog/colors/data/datasources/color_stats_remote_data_source_impl.dart';
import '../../support/fake_colors_api_client.dart';

void main() {
  test('uses color_stats RPC and maps usage aggregates', () async {
    final api = FakeColorsApiClient()
      ..totalCount = 8
      ..activeCount = 5;
    final result = await ColorStatsRemoteDataSourceImpl(api).getColorStats();

    expect(result, isA<ApiSuccess>());
    final stats = (result as ApiSuccess).data;
    expect(stats.total, 8);
    expect(stats.active, 5);
    expect(stats.inactive, 3);
    expect(stats.used, 6);
    expect(stats.unused, 2);
    expect(api.lastPath, ColorsEndpoint.statsRpc.toStringPath());
    expect(api.paginatedQueries, isEmpty);
  });
}
