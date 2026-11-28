import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/error/exceptions/api_exception.dart';
import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/features/catalog/fabric_types/data/datasources/fabric_types_remote_data_source.dart';
import 'package:accounting_software/app/features/catalog/fabric_types/data/models/fabric_type_model.dart';
import 'package:accounting_software/app/features/catalog/fabric_types/data/repositories/fabric_types_repository_impl.dart';
import 'package:accounting_software/app/features/catalog/fabric_types/domain/entity/fabric_type_draft.dart';
import 'package:accounting_software/app/features/catalog/fabric_types/domain/entity/fabric_type_list_query.dart';
import 'package:accounting_software/app/features/catalog/fabric_types/domain/failures/fabric_type_failures.dart';

class _FakeFabricTypesRemote implements FabricTypesRemoteDataSource {
  ApiResult<FabricTypeModel> createResult = const ApiSuccess(
    FabricTypeModel(
      id: 1,
      name: 'Jersey',
      code: 'JER',
      isActive: true,
      isNamedFabric: false,
    ),
  );
  ApiResult<Unit> deleteResult = const ApiSuccess(unit);
  @override
  Future<ApiResult<PaginatedResult<FabricTypeModel>>> getFabricTypes(
    FabricTypeListQuery query,
  ) async => const ApiSuccess(
    PaginatedResult(items: [], totalCount: 0, currentPage: 1, totalPages: 0),
  );
  @override
  Future<ApiResult<FabricTypeModel>> createFabricType(
    FabricTypeDraft draft,
  ) async => createResult;
  @override
  Future<ApiResult<FabricTypeModel>> updateFabricType({
    required int id,
    required FabricTypeDraft draft,
  }) async => createResult;
  @override
  Future<ApiResult<Unit>> deleteFabricType(int id) async => deleteResult;
  @override
  Future<ApiResult<Unit>> setFabricTypeActive({
    required int id,
    required bool isActive,
  }) async => const ApiSuccess(unit);
}

void main() {
  group('FabricTypesRepositoryImpl', () {
    test('maps unique code conflict to duplicate failure', () async {
      final remote = _FakeFabricTypesRemote()
        ..createResult = ApiFailure(ApiException.conflict(errorCode: '23505'));
      final result = await FabricTypesRepositoryImpl(
        remote,
      ).createFabricType(const FabricTypeDraft(name: 'Jersey', code: 'JER'));
      expect(
        result.fold((failure) => failure, (_) => null),
        isA<FabricTypeDuplicateFailure>(),
      );
    });
    test('maps foreign key delete rejection to in-use failure', () async {
      final remote = _FakeFabricTypesRemote()
        ..deleteResult = ApiFailure(ApiException.conflict(errorCode: '23503'));
      final result = await FabricTypesRepositoryImpl(
        remote,
      ).deleteFabricType(1);
      expect(
        result.fold((failure) => failure, (_) => null),
        isA<FabricTypeInUseFailure>(),
      );
    });
  });
}
