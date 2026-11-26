import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/error/mappers/exception_mapper.dart';
import 'package:accounting_software/app/core/foundation/base/repository_executor.dart';
import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/features/catalog/attributes/data/datasources/attributes_remote_data_source.dart';
import 'package:accounting_software/app/features/catalog/attributes/data/models/attribute_model.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/entity/attribute_draft.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/entity/attribute_list_query.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/entity/catalog_attribute.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/repositories/attributes_repository.dart';

class AttributesRepositoryImpl with RepositoryExecutor implements AttributesRepository {
  const AttributesRepositoryImpl(this._remote);
  final AttributesRemoteDataSource _remote;

  @override
  Future<Either<Failure, PaginatedResult<CatalogAttribute>>> getAttributes(AttributeListQuery query) => execute(() async {
    final result = await _remote.getAttributes(query);
    return switch (result) {
      ApiSuccess<PaginatedResult<AttributeModel>>(:final data) => Right(PaginatedResult<CatalogAttribute>(
        items: data.items.map((item) => item.toEntity()).toList(),
        totalCount: data.totalCount, currentPage: data.currentPage,
        totalPages: data.totalPages, isFromCache: data.isFromCache,
      )),
      ApiFailure<PaginatedResult<AttributeModel>>(:final exception) => Left(ExceptionMapper.map(exception)),
    };
  });

  @override
  Future<Either<Failure, CatalogAttribute>> createAttribute(AttributeDraft draft) => _write(() => _remote.createAttribute(draft));
  @override
  Future<Either<Failure, CatalogAttribute>> updateAttribute({required int id, required AttributeDraft draft}) =>
      _write(() => _remote.updateAttribute(id: id, draft: draft));

  Future<Either<Failure, CatalogAttribute>> _write(Future<ApiResult<AttributeModel>> Function() request) => execute(() async {
    final result = await request();
    return switch (result) {
      ApiSuccess<AttributeModel>(:final data) => Right(data.toEntity()),
      ApiFailure<AttributeModel>(:final exception) => Left(ExceptionMapper.map(exception)),
    };
  });

  @override
  Future<Either<Failure, Unit>> setAttributeActive({required int id, required bool isActive}) => execute(() async {
    final result = await _remote.setAttributeActive(id: id, isActive: isActive);
    return switch (result) {
      ApiSuccess<Unit>() => const Right(unit),
      ApiFailure<Unit>(:final exception) => Left(ExceptionMapper.map(exception)),
    };
  });

  @override
  Future<Either<Failure, List<AttributeUnitChoice>>> getUnitChoices() => execute(() async {
    final result = await _remote.getUnitChoices();
    return switch (result) {
      ApiSuccess<List<AttributeUnitChoice>>(:final data) => Right(data),
      ApiFailure<List<AttributeUnitChoice>>(:final exception) => Left(ExceptionMapper.map(exception)),
    };
  });

  @override
  Future<Either<Failure, List<AttributeOptionSetChoice>>> getOptionSetChoices() => execute(() async {
    final result = await _remote.getOptionSetChoices();
    return switch (result) {
      ApiSuccess<List<AttributeOptionSetChoice>>(:final data) => Right(data),
      ApiFailure<List<AttributeOptionSetChoice>>(:final exception) => Left(ExceptionMapper.map(exception)),
    };
  });
}
