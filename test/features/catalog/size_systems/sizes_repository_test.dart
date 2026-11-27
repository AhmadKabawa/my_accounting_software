import 'package:dartz/dartz.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/features/catalog/size_systems/sizes/data/datasources/sizes_remote_data_source.dart';
import 'package:accounting_software/app/features/catalog/size_systems/sizes/data/models/catalog_size_model.dart';
import 'package:accounting_software/app/features/catalog/size_systems/sizes/data/repositories/sizes_repository_impl.dart';
import 'package:accounting_software/app/features/catalog/size_systems/sizes/domain/entity/catalog_size_draft.dart';
import 'package:accounting_software/app/features/catalog/size_systems/sizes/domain/entity/catalog_size_list_query.dart';

class _FakeSizesRemote implements SizesRemoteDataSource {
  List<CatalogSizeDraft>? lastBatch;
  int batchCalls = 0;

  CatalogSizeModel _model(int id, CatalogSizeDraft d) => CatalogSizeModel(
    id: id,
    sizeGroupId: d.sizeGroupId,
    name: d.name,
    code: d.code,
    numericValue: d.numericValue,
    sortOrder: d.sortOrder,
    isActive: d.isActive,
  );

  @override
  Future<ApiResult<List<CatalogSizeModel>>> createSizes(
    List<CatalogSizeDraft> drafts,
  ) async {
    batchCalls++;
    lastBatch = drafts;
    return ApiSuccess([
      for (var i = 0; i < drafts.length; i++) _model(i + 1, drafts[i]),
    ]);
  }

  @override
  Future<ApiResult<PaginatedResult<CatalogSizeModel>>> getSizes(
    CatalogSizeListQuery query,
  ) async => ApiSuccess(
    PaginatedResult<CatalogSizeModel>(
      items: const [
        CatalogSizeModel(
          id: 1,
          sizeGroupId: 7,
          name: '36',
          code: 'EU36',
          sortOrder: 0,
          isActive: true,
          productCount: 0,
        ),
      ],
      totalCount: 1,
      currentPage: 1,
      totalPages: 1,
      isFromCache: false,
    ),
  );

  @override
  Future<ApiResult<CatalogSizeModel>> createSize(CatalogSizeDraft draft) async =>
      ApiSuccess(_model(1, draft));

  @override
  Future<ApiResult<CatalogSizeModel>> updateSize({
    required int id,
    required CatalogSizeDraft draft,
  }) async => ApiSuccess(_model(id, draft));

  @override
  Future<ApiResult<Unit>> deleteSize(int id) async => ApiSuccess(unit);

  @override
  Future<ApiResult<Unit>> setSizeActive({
    required int id,
    required bool isActive,
  }) async => ApiSuccess(unit);
}

void main() {
  late _FakeSizesRemote remote;
  late SizesRepositoryImpl repository;

  setUp(() {
    remote = _FakeSizesRemote();
    repository = SizesRepositoryImpl(remote);
  });

  test('getSizes maps models to entities with the usage count', () async {
    final result = await repository.getSizes(
      const CatalogSizeListQuery(sizeGroupId: 7),
    );
    final page = result.getOrElse(() => throw StateError('expected a page'));
    expect(page.items.single.code, 'EU36');
    expect(page.items.single.canDelete, isTrue);
    expect(page.totalCount, 1);
  });

  test('createSizes sends one batch call and returns every row', () async {
    final drafts = [
      for (var i = 36; i <= 46; i++)
        CatalogSizeDraft(
          sizeGroupId: 7,
          name: '$i',
          code: 'EU$i',
          numericValue: Decimal.fromInt(i),
          sortOrder: i - 36,
        ),
    ];
    final result = await repository.createSizes(drafts);
    final created = result.getOrElse(() => throw StateError('expected rows'));
    expect(remote.batchCalls, 1);
    expect(remote.lastBatch, hasLength(11));
    expect(created, hasLength(11));
    expect(created.first.numericValue, Decimal.fromInt(36));
  });
}
