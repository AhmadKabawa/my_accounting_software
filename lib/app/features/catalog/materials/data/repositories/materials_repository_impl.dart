import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/exceptions/api_exception.dart';
import 'package:accounting_software/app/core/error/exceptions/app_exception.dart';
import 'package:accounting_software/app/features/catalog/materials/domain/failures/material_failures.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/error/mappers/exception_mapper.dart';
import 'package:accounting_software/app/core/foundation/base/repository_executor.dart';
import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/features/catalog/materials/data/datasources/materials_remote_data_source.dart';
import 'package:accounting_software/app/features/catalog/materials/data/models/material_model.dart';
import 'package:accounting_software/app/features/catalog/materials/domain/entity/material.dart';
import 'package:accounting_software/app/features/catalog/materials/domain/entity/material_draft.dart';
import 'package:accounting_software/app/features/catalog/materials/domain/entity/material_list_query.dart';
import 'package:accounting_software/app/features/catalog/materials/domain/repository/materials_repository.dart';

class MaterialsRepositoryImpl
    with RepositoryExecutor
    implements MaterialsRepository {
  const MaterialsRepositoryImpl(this._remote);
  final MaterialsRemoteDataSource _remote;
  @override
  Future<Either<Failure, PaginatedResult<CatalogMaterial>>> getMaterials(
    MaterialListQuery q,
  ) => execute(() async {
    final r = await _remote.getMaterials(q);
    return switch (r) {
      ApiSuccess<PaginatedResult<MaterialModel>>(:final data) => Right(
        PaginatedResult<CatalogMaterial>(
          items: data.items.map((e) => e.toEntity()).toList(),
          totalCount: data.totalCount,
          currentPage: data.currentPage,
          totalPages: data.totalPages,
          isFromCache: data.isFromCache,
        ),
      ),
      ApiFailure<PaginatedResult<MaterialModel>>(:final exception) => Left(
        ExceptionMapper.map(exception),
      ),
    };
  });
  @override
  Future<Either<Failure, CatalogMaterial>> createMaterial(MaterialDraft d) =>
      execute(() async {
        final r = await _remote.createMaterial(d);
        return switch (r) {
          ApiSuccess<MaterialModel>(:final data) => Right(data.toEntity()),
          ApiFailure<MaterialModel>(:final exception) => Left(_mapWriteFailure(exception)),
        };
      });
  @override
  Future<Either<Failure, CatalogMaterial>> updateMaterial({
    required int id,
    required MaterialDraft draft,
  }) => execute(() async {
    final r = await _remote.updateMaterial(id: id, draft: draft);
    return switch (r) {
      ApiSuccess<MaterialModel>(:final data) => Right(data.toEntity()),
      ApiFailure<MaterialModel>(:final exception) => Left(_mapWriteFailure(exception)),
    };
  });
  @override
  Future<Either<Failure, Unit>> deleteMaterial(int id) => execute(() async {
    final r = await _remote.deleteMaterial(id);
    return switch (r) {
      ApiSuccess<Unit>() => const Right(unit),
      ApiFailure<Unit>(:final exception) => Left(
        exception is ApiException && exception.errorCode == '23503' ? const MaterialInUseFailure() : ExceptionMapper.map(exception),
      ),
    };
  });
  @override
  Future<Either<Failure, Unit>> setMaterialActive({
    required int id,
    required bool isActive,
  }) => execute(() async {
    final r = await _remote.setMaterialActive(id: id, isActive: isActive);
    return switch (r) {
      ApiSuccess<Unit>() => const Right(unit),
      ApiFailure<Unit>(:final exception) => Left(
        ExceptionMapper.map(exception),
      ),
    };
  });
  Failure _mapWriteFailure(AppException exception) => exception is ApiException && exception.errorCode == '23505' ? const MaterialDuplicateFailure() : ExceptionMapper.map(exception);
}
