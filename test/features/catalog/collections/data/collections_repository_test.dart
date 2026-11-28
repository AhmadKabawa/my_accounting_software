import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/error/exceptions/api_exception.dart';
import 'package:accounting_software/app/core/foundation/image/image_upload.dart';
import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/features/catalog/collections/data/datasources/collections_remote_data_source.dart';
import 'package:accounting_software/app/features/catalog/collections/data/models/collection_model.dart';
import 'package:accounting_software/app/features/catalog/collections/data/repositories/collections_repository_impl.dart';
import 'package:accounting_software/app/features/catalog/collections/domain/entity/collection_draft.dart';
import 'package:accounting_software/app/features/catalog/collections/domain/entity/collection_list_query.dart';
import 'package:accounting_software/app/features/catalog/collections/domain/failures/collection_failures.dart';

class _FakeCollectionsRemote implements CollectionsRemoteDataSource {
  ApiResult<CollectionModel> createResult = const ApiSuccess(
    CollectionModel(
      id: 1,
      name: 'Summer capsule',
      code: 'SUM-CAP',
      isActive: true,
    ),
  );
  ApiResult<Unit> deleteResult = const ApiSuccess(unit);
  ApiResult<String> uploadResult = const ApiSuccess(
    'https://cdn.example.test/collections/summer.webp',
  );

  @override
  Future<ApiResult<PaginatedResult<CollectionModel>>> getCollections(
    CollectionListQuery query,
  ) async => const ApiSuccess(
    PaginatedResult(items: [], totalCount: 0, currentPage: 1, totalPages: 0),
  );

  @override
  Future<ApiResult<CollectionModel>> createCollection(
    CollectionDraft draft,
  ) async => createResult;

  @override
  Future<ApiResult<CollectionModel>> updateCollection({
    required int id,
    required CollectionDraft draft,
  }) async => createResult;

  @override
  Future<ApiResult<Unit>> deleteCollection(int id) async => deleteResult;

  @override
  Future<ApiResult<Unit>> setCollectionActive({
    required int id,
    required bool isActive,
  }) async => const ApiSuccess(unit);

  @override
  Future<ApiResult<String>> uploadImage(ImageUpload image) async =>
      uploadResult;
}

void main() {
  group('CollectionsRepositoryImpl', () {
    test('maps unique code conflict to duplicate failure', () async {
      final remote = _FakeCollectionsRemote()
        ..createResult = ApiFailure(ApiException.conflict(errorCode: '23505'));
      final result = await CollectionsRepositoryImpl(remote).createCollection(
        const CollectionDraft(name: 'Summer capsule', code: 'SUM-CAP'),
      );
      expect(
        result.fold((failure) => failure, (_) => null),
        isA<CollectionDuplicateFailure>(),
      );
    });

    test('maps foreign key delete rejection to in-use failure', () async {
      final remote = _FakeCollectionsRemote()
        ..deleteResult = ApiFailure(ApiException.conflict(errorCode: '23503'));
      final result = await CollectionsRepositoryImpl(
        remote,
      ).deleteCollection(1);
      expect(
        result.fold((failure) => failure, (_) => null),
        isA<CollectionInUseFailure>(),
      );
    });

    test('returns uploaded image URL from the repository', () async {
      final result = await CollectionsRepositoryImpl(_FakeCollectionsRemote())
          .uploadImage(
            ImageUpload(
              bytes: Uint8List.fromList([0xff, 0xd8, 0xff]),
              fileName: 'collection.jpg',
              mimeType: 'image/jpeg',
            ),
          );
      expect(
        result.fold((failure) => failure, (url) => url),
        'https://cdn.example.test/collections/summer.webp',
      );
    });
  });
}
