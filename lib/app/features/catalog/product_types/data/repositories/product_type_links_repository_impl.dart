import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/exceptions/api_exception.dart';
import 'package:accounting_software/app/core/error/exceptions/app_exception.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/error/mappers/exception_mapper.dart';
import 'package:accounting_software/app/core/foundation/base/repository_executor.dart';
import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/features/catalog/product_types/data/datasources/product_type_links_remote_data_source.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/entity/product_type_attribute_link.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/entity/product_type_link_option.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/entity/product_type_option_set_link.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/entity/product_type_size_group_link.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/failures/product_type_failures.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/repositories/product_type_links_repository.dart';

class ProductTypeLinksRepositoryImpl
    with RepositoryExecutor
    implements ProductTypeLinksRepository {
  const ProductTypeLinksRepositoryImpl(this._remote);

  final ProductTypeLinksRemoteDataSource _remote;

  @override
  Future<Either<Failure, List<ProductTypeSizeGroupLink>>> getSizeGroupLinks(
    int id,
  ) => execute(() async => (await _remote.getSizeGroupLinks(id)).toEither());

  @override
  Future<Either<Failure, List<ProductTypeAttributeLink>>> getAttributeLinks(
    int id,
  ) => execute(() async => (await _remote.getAttributeLinks(id)).toEither());

  @override
  Future<Either<Failure, List<ProductTypeOptionSetLink>>> getOptionSetLinks(
    int id,
  ) => execute(() async => (await _remote.getOptionSetLinks(id)).toEither());

  @override
  Future<Either<Failure, List<ProductTypeLinkOption>>> getSizeGroupOptions() =>
      execute(() async => (await _remote.getSizeGroupOptions()).toEither());

  @override
  Future<Either<Failure, List<ProductTypeLinkOption>>> getAttributeOptions() =>
      execute(() async => (await _remote.getAttributeOptions()).toEither());

  @override
  Future<Either<Failure, List<ProductTypeLinkOption>>> getOptionSetOptions() =>
      execute(() async => (await _remote.getOptionSetOptions()).toEither());

  @override
  Future<Either<Failure, List<ProductTypeLinkOption>>> getGenderOptions() =>
      execute(() async => (await _remote.getGenderOptions()).toEither());

  @override
  Future<Either<Failure, Unit>> createSizeGroupLink(
    Map<String, dynamic> body,
  ) => execute(() async {
    final result = await _remote.createSizeGroupLink(body);
    return switch (result) {
      ApiSuccess<Unit>() => const Right(unit),
      ApiFailure<Unit>(:final exception) => Left(
        _mapDefaultSizeGroupFailure(exception),
      ),
    };
  });

  @override
  Future<Either<Failure, Unit>> patchSizeGroupLink(
    int id,
    Map<String, dynamic> body,
  ) => execute(() async {
    final result = await _remote.patchSizeGroupLink(id, body);
    return switch (result) {
      ApiSuccess<Unit>() => const Right(unit),
      ApiFailure<Unit>(:final exception) => Left(
        _mapDefaultSizeGroupFailure(exception),
      ),
    };
  });

  @override
  Future<Either<Failure, Unit>> deleteSizeGroupLink(int id) =>
      execute(() async => (await _remote.deleteSizeGroupLink(id)).toEither());

  /// The partial unique index prevents two default size groups for the same
  /// product type and gender. Map only diagnostics that identify that index;
  /// other unique violations (for example a duplicate link) keep their generic
  /// database error rather than showing the wrong message.
  Failure _mapDefaultSizeGroupFailure(AppException exception) {
    if (exception is ApiException && exception.errorCode == '23505') {
      final diagnostic = '${exception.message} ${exception.details}'
          .toLowerCase();
      if (diagnostic.contains('ux_pt_size_groups_one_default') ||
          diagnostic.contains('product_type_id, gender_id')) {
        return const ProductTypeDefaultSizeGroupConflictFailure();
      }
    }
    return ExceptionMapper.map(exception);
  }

  @override
  Future<Either<Failure, Unit>> createAttributeLink(
    Map<String, dynamic> body,
  ) =>
      execute(() async => (await _remote.createAttributeLink(body)).toEither());

  @override
  Future<Either<Failure, Unit>> patchAttributeLink(
    int productTypeId,
    int attributeId,
    Map<String, dynamic> body,
  ) => execute(
    () async => (await _remote.patchAttributeLink(
      productTypeId,
      attributeId,
      body,
    )).toEither(),
  );

  @override
  Future<Either<Failure, Unit>> deleteAttributeLink(
    int productTypeId,
    int attributeId,
  ) => execute(
    () async => (await _remote.deleteAttributeLink(
      productTypeId,
      attributeId,
    )).toEither(),
  );

  @override
  Future<Either<Failure, Unit>> createOptionSetLink(
    Map<String, dynamic> body,
  ) =>
      execute(() async => (await _remote.createOptionSetLink(body)).toEither());

  @override
  Future<Either<Failure, Unit>> patchOptionSetLink(
    int productTypeId,
    int optionSetId,
    Map<String, dynamic> body,
  ) => execute(
    () async => (await _remote.patchOptionSetLink(
      productTypeId,
      optionSetId,
      body,
    )).toEither(),
  );

  @override
  Future<Either<Failure, Unit>> deleteOptionSetLink(
    int productTypeId,
    int optionSetId,
  ) => execute(
    () async => (await _remote.deleteOptionSetLink(
      productTypeId,
      optionSetId,
    )).toEither(),
  );

  @override
  Future<Either<Failure, int>> getPublishedProductCount(int productTypeId) =>
      execute(
        () async =>
            (await _remote.getPublishedProductCount(productTypeId)).toEither(),
      );
}
