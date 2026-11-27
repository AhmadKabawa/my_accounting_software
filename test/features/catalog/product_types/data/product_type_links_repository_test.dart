import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:accounting_software/app/core/error/exceptions/api_exception.dart';
import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/features/catalog/product_types/data/datasources/product_type_links_remote_data_source.dart';
import 'package:accounting_software/app/features/catalog/product_types/data/repositories/product_type_links_repository_impl.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/failures/product_type_failures.dart';

class _LinksRemote extends Fake implements ProductTypeLinksRemoteDataSource {
  ApiException? writeFailure;

  @override
  Future<ApiResult<Unit>> createSizeGroupLink(
    Map<String, dynamic> body,
  ) async {
    final failure = writeFailure;
    return failure == null ? const ApiSuccess(unit) : ApiFailure(failure);
  }

  @override
  Future<ApiResult<Unit>> patchSizeGroupLink(
    int id,
    Map<String, dynamic> body,
  ) async {
    final failure = writeFailure;
    return failure == null ? const ApiSuccess(unit) : ApiFailure(failure);
  }
}

void main() {
  late _LinksRemote remote;
  late ProductTypeLinksRepositoryImpl repository;

  setUp(() {
    remote = _LinksRemote();
    repository = ProductTypeLinksRepositoryImpl(remote);
  });

  test('maps the default size-group unique index conflict', () async {
    remote.writeFailure = ApiException.conflict(
      errorCode: '23505',
      serverMessage: 'duplicate key violates ux_pt_size_groups_one_default',
      details: 'ux_pt_size_groups_one_default',
    );

    final result = await repository.createSizeGroupLink({
      'product_type_id': 1,
      'size_group_id': 2,
      'gender_id': 3,
      'is_default': true,
    });

    expect(
      result.fold((failure) => failure, (_) => null),
      isA<ProductTypeDefaultSizeGroupConflictFailure>(),
    );
  });

  test(
    'does not mislabel another unique violation as default conflict',
    () async {
      remote.writeFailure = ApiException.conflict(
        errorCode: '23505',
        serverMessage: 'duplicate link',
        details: 'Key (product_type_id, size_group_id) already exists',
      );

      final result = await repository.patchSizeGroupLink(
        9,
        {'is_default': true},
      );

      expect(result.isLeft(), isTrue);
      expect(
        result.fold((failure) => failure, (_) => null),
        isNot(isA<ProductTypeDefaultSizeGroupConflictFailure>()),
      );
    },
  );
}
