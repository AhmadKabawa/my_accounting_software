import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/error/exceptions/api_exception.dart';
import 'package:accounting_software/app/features/catalog/sports/data/datasources/sports_remote_data_source_impl.dart';
import 'package:accounting_software/app/features/catalog/sports/data/datasources/sport_stats_remote_data_source.dart';
import 'package:accounting_software/app/features/catalog/sports/data/repositories/sports_repository_impl.dart';
import 'package:accounting_software/app/features/catalog/sports/domain/entity/sport_draft.dart';
import 'package:accounting_software/app/features/catalog/sports/domain/failures/sport_failures.dart';
import '../../support/fake_catalog_api_client.dart';

class _StatsRemote extends Mock implements SportStatsRemoteDataSource {}

void main() {
  const response = {
    'id': 8,
    'name': 'Running',
    'code': 'RUNNING',
    'description': null,
    'sort_order': 2,
    'is_active': false,
  };

  test('POST includes is_active and trims the sport fields', () async {
    final api = FakeCatalogApiClient()..writeRow = response;
    final remote = SportsRemoteDataSourceImpl(api);

    await remote.createSport(
      const SportDraft(
        name: ' Running ',
        code: ' RUNNING ',
        isActive: false,
        sortOrder: 2,
      ),
    );

    expect(api.lastRequest.method, 'POST');
    expect(api.lastRequest.body, {
      'name': 'Running',
      'code': 'RUNNING',
      'description': null,
      'sort_order': 2,
      'is_active': false,
    });
  });

  test(
    'PATCH omits is_active when unchanged and includes it when changed',
    () async {
      final api = FakeCatalogApiClient()..writeRow = response;
      final remote = SportsRemoteDataSourceImpl(api);

      await remote.updateSport(
        id: 8,
        draft: const SportDraft(name: 'Running', code: 'RUNNING'),
      );
      expect(api.lastRequest.body!.containsKey('is_active'), isFalse);

      await remote.updateSport(
        id: 8,
        draft: const SportDraft(
          name: 'Running',
          code: 'RUNNING',
          isActive: true,
        ),
      );
      expect(api.lastRequest.body!['is_active'], isTrue);
    },
  );

  test('23505 is mapped to a sport duplicate failure', () async {
    final api = FakeCatalogApiClient()
      ..nextPostFailure = ApiException.conflict(errorCode: '23505');
    final repository = SportsRepositoryImpl(
      SportsRemoteDataSourceImpl(api),
      _StatsRemote(),
    );

    final result = await repository.createSport(
      const SportDraft(name: 'Running', code: 'RUNNING'),
    );

    expect(
      result.fold((failure) => failure, (_) => null),
      isA<SportDuplicateFailure>(),
    );
  });
}
