import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/error/exceptions/api_exception.dart';
import 'package:accounting_software/app/features/catalog/tags/data/datasources/tags_remote_data_source_impl.dart';
import 'package:accounting_software/app/features/catalog/tags/data/datasources/tag_stats_remote_data_source.dart';
import 'package:accounting_software/app/features/catalog/tags/data/repositories/tags_repository_impl.dart';
import 'package:accounting_software/app/features/catalog/tags/domain/entity/catalog_tag_draft.dart';
import 'package:accounting_software/app/features/catalog/tags/domain/failures/tag_failures.dart';
import '../../support/fake_catalog_api_client.dart';

class _StatsRemote extends Mock implements TagStatsRemoteDataSource {}

void main() {
  const response = {
    'id': 9,
    'name': 'New Arrival',
    'slug': 'new-arrival',
    'is_active': false,
  };

  test('POST includes is_active and trims the tag fields', () async {
    final api = FakeCatalogApiClient()..writeRow = response;
    final remote = TagsRemoteDataSourceImpl(api);

    await remote.createTag(
      const CatalogTagDraft(
        name: ' New Arrival ',
        slug: ' new-arrival ',
        isActive: false,
      ),
    );

    expect(api.lastRequest.method, 'POST');
    expect(api.lastRequest.body, {
      'name': 'New Arrival',
      'slug': 'new-arrival',
      'is_active': false,
    });
  });

  test('PATCH omits is_active when unchanged and includes it when changed', () async {
    final api = FakeCatalogApiClient()..writeRow = response;
    final remote = TagsRemoteDataSourceImpl(api);

    await remote.updateTag(
      id: 9,
      draft: const CatalogTagDraft(name: 'New Arrival', slug: 'new-arrival'),
    );
    expect(api.lastRequest.body!.containsKey('is_active'), isFalse);

    await remote.updateTag(
      id: 9,
      draft: const CatalogTagDraft(
        name: 'New Arrival',
        slug: 'new-arrival',
        isActive: true,
      ),
    );
    expect(api.lastRequest.body!['is_active'], isTrue);
  });

  test('23505 for the unique name or slug maps to a tag duplicate failure', () async {
    final api = FakeCatalogApiClient()
      ..nextPostFailure = ApiException.conflict(errorCode: '23505');
    final repository = TagsRepositoryImpl(
      TagsRemoteDataSourceImpl(api),
      _StatsRemote(),
    );

    final result = await repository.createTag(
      const CatalogTagDraft(name: 'New Arrival', slug: 'new-arrival'),
    );

    expect(result.fold((failure) => failure, (_) => null),
        isA<TagDuplicateFailure>());
  });
}
