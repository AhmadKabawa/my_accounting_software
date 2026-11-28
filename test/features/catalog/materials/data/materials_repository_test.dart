import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/error/exceptions/api_exception.dart';
import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/features/catalog/materials/data/datasources/materials_remote_data_source.dart';
import 'package:accounting_software/app/features/catalog/materials/data/models/material_model.dart';
import 'package:accounting_software/app/features/catalog/materials/data/repositories/materials_repository_impl.dart';
import 'package:accounting_software/app/features/catalog/materials/domain/entity/material_draft.dart';
import 'package:accounting_software/app/features/catalog/materials/domain/entity/material_list_query.dart';
import 'package:accounting_software/app/features/catalog/materials/domain/failures/material_failures.dart';

class _FakeMaterialsRemote implements MaterialsRemoteDataSource {
  ApiResult<MaterialModel> createResult = const ApiSuccess(
    MaterialModel(id: 1, name: 'Cotton', code: 'COT', isActive: true),
  );
  ApiResult<Unit> deleteResult = const ApiSuccess(unit);
  @override
  Future<ApiResult<PaginatedResult<MaterialModel>>> getMaterials(
    MaterialListQuery query,
  ) async => const ApiSuccess(
    PaginatedResult(items: [], totalCount: 0, currentPage: 1, totalPages: 0),
  );
  @override
  Future<ApiResult<MaterialModel>> createMaterial(MaterialDraft draft) async =>
      createResult;
  @override
  Future<ApiResult<MaterialModel>> updateMaterial({
    required int id,
    required MaterialDraft draft,
  }) async => createResult;
  @override
  Future<ApiResult<Unit>> deleteMaterial(int id) async => deleteResult;
  @override
  Future<ApiResult<Unit>> setMaterialActive({
    required int id,
    required bool isActive,
  }) async => const ApiSuccess(unit);
}

void main() {
  group('MaterialsRepositoryImpl', () {
    test('maps unique code conflict to duplicate failure', () async {
      final remote = _FakeMaterialsRemote()
        ..createResult = ApiFailure(ApiException.conflict(errorCode: '23505'));
      final result = await MaterialsRepositoryImpl(
        remote,
      ).createMaterial(const MaterialDraft(name: 'Cotton', code: 'COT'));
      expect(
        result.fold((failure) => failure, (_) => null),
        isA<MaterialDuplicateFailure>(),
      );
    });
    test('maps foreign key delete rejection to in-use failure', () async {
      final remote = _FakeMaterialsRemote()
        ..deleteResult = ApiFailure(ApiException.conflict(errorCode: '23503'));
      final result = await MaterialsRepositoryImpl(remote).deleteMaterial(1);
      expect(
        result.fold((failure) => failure, (_) => null),
        isA<MaterialInUseFailure>(),
      );
    });
  });
}
