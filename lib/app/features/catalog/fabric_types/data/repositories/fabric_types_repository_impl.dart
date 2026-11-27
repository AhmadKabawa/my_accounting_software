import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/exceptions/api_exception.dart';
import 'package:accounting_software/app/core/error/exceptions/app_exception.dart';
import 'package:accounting_software/app/features/catalog/fabric_types/domain/failures/fabric_type_failures.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/error/mappers/exception_mapper.dart';
import 'package:accounting_software/app/core/foundation/base/repository_executor.dart';
import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/features/catalog/fabric_types/data/datasources/fabric_types_remote_data_source.dart';
import 'package:accounting_software/app/features/catalog/fabric_types/data/models/fabric_type_model.dart';
import 'package:accounting_software/app/features/catalog/fabric_types/domain/entity/fabric_type.dart';
import 'package:accounting_software/app/features/catalog/fabric_types/domain/entity/fabric_type_draft.dart';
import 'package:accounting_software/app/features/catalog/fabric_types/domain/entity/fabric_type_list_query.dart';
import 'package:accounting_software/app/features/catalog/fabric_types/domain/repository/fabric_types_repository.dart';

class FabricTypesRepositoryImpl
    with RepositoryExecutor
    implements FabricTypesRepository {
  const FabricTypesRepositoryImpl(this._remote);
  final FabricTypesRemoteDataSource _remote;
  @override
  Future<Either<Failure, PaginatedResult<CatalogFabricType>>> getFabricTypes(
    FabricTypeListQuery q,
  ) => execute(() async {
    final r = await _remote.getFabricTypes(q);
    return switch (r) {
      ApiSuccess<PaginatedResult<FabricTypeModel>>(:final data) => Right(
        PaginatedResult<CatalogFabricType>(
          items: data.items.map((e) => e.toEntity()).toList(),
          totalCount: data.totalCount,
          currentPage: data.currentPage,
          totalPages: data.totalPages,
          isFromCache: data.isFromCache,
        ),
      ),
      ApiFailure<PaginatedResult<FabricTypeModel>>(:final exception) => Left(
        ExceptionMapper.map(exception),
      ),
    };
  });
  @override
  Future<Either<Failure, CatalogFabricType>> createFabricType(
    FabricTypeDraft d,
  ) => execute(() async {
    final r = await _remote.createFabricType(d);
    return switch (r) {
      ApiSuccess<FabricTypeModel>(:final data) => Right(data.toEntity()),
      ApiFailure<FabricTypeModel>(:final exception) => Left(_mapWriteFailure(exception)),
    };
  });
  @override
  Future<Either<Failure, CatalogFabricType>> updateFabricType({
    required int id,
    required FabricTypeDraft draft,
  }) => execute(() async {
    final r = await _remote.updateFabricType(id: id, draft: draft);
    return switch (r) {
      ApiSuccess<FabricTypeModel>(:final data) => Right(data.toEntity()),
      ApiFailure<FabricTypeModel>(:final exception) => Left(_mapWriteFailure(exception)),
    };
  });
  @override
  Future<Either<Failure, Unit>> deleteFabricType(int id) => execute(() async {
    final r = await _remote.deleteFabricType(id);
    return switch (r) {
      ApiSuccess<Unit>() => const Right(unit),
      ApiFailure<Unit>(:final exception) => Left(
        exception is ApiException && exception.errorCode == '23503' ? const FabricTypeInUseFailure() : ExceptionMapper.map(exception),
      ),
    };
  });
  @override
  Future<Either<Failure, Unit>> setFabricTypeActive({
    required int id,
    required bool isActive,
  }) => execute(() async {
    final r = await _remote.setFabricTypeActive(id: id, isActive: isActive);
    return switch (r) {
      ApiSuccess<Unit>() => const Right(unit),
      ApiFailure<Unit>(:final exception) => Left(
        ExceptionMapper.map(exception),
      ),
    };
  });
  Failure _mapWriteFailure(AppException exception) => exception is ApiException && exception.errorCode == '23505' ? const FabricTypeDuplicateFailure() : ExceptionMapper.map(exception);
}
