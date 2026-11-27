import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/exceptions/api_exception.dart';
import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/features/catalog/genders/data/datasources/gender_stats_remote_data_source.dart';
import 'package:accounting_software/app/features/catalog/genders/data/datasources/genders_remote_data_source.dart';
import 'package:accounting_software/app/features/catalog/genders/data/models/gender_model.dart';
import 'package:accounting_software/app/features/catalog/genders/data/repositories/genders_repository_impl.dart';
import 'package:accounting_software/app/features/catalog/genders/domain/entity/gender_draft.dart';
import 'package:accounting_software/app/features/catalog/genders/domain/entity/gender_list_query.dart';
import 'package:accounting_software/app/features/catalog/genders/domain/entity/gender_stats.dart';
import 'package:accounting_software/app/features/catalog/genders/domain/failures/gender_failures.dart';
import 'package:flutter_test/flutter_test.dart';

class _GenderRemote implements GendersRemoteDataSource {
  ApiResult<GenderModel> write = ApiFailure(
    ApiException.conflict(errorCode: '23505'),
  );
  ApiResult<Unit> remove = ApiFailure(
    ApiException.conflict(errorCode: '23503'),
  );

  @override
  Future<ApiResult<GenderModel>> createGender(GenderDraft draft) async => write;
  @override
  Future<ApiResult<GenderModel>> updateGender({
    required int id,
    required GenderDraft draft,
  }) async => write;
  @override
  Future<ApiResult<Unit>> deleteGender(int id) async => remove;
  @override
  Future<ApiResult<Unit>> setGenderActive({
    required int id,
    required bool isActive,
  }) async => ApiFailure(ApiException.unknown());
  @override
  Future<ApiResult<PaginatedResult<GenderModel>>> getGenders(
    GenderListQuery query,
  ) async => ApiFailure(ApiException.unknown());
}

class _StatsRemote implements GenderStatsRemoteDataSource {
  @override
  Future<ApiResult<GenderStats>> getGenderStats() async =>
      const ApiSuccess(GenderStats(total: 0, active: 0, inactive: 0));
}

void main() {
  late _GenderRemote remote;
  late GendersRepositoryImpl repository;

  setUp(() {
    remote = _GenderRemote();
    repository = GendersRepositoryImpl(remote, _StatsRemote());
  });

  test('23505 maps to duplicate failure on create and update', () async {
    final create = await repository.createGender(
      const GenderDraft(name: 'Women', code: 'W'),
    );
    create.fold(
      (failure) => expect(failure, isA<GenderDuplicateFailure>()),
      (_) => fail('Expected duplicate failure'),
    );

    final update = await repository.updateGender(
      id: 1,
      draft: const GenderDraft(name: 'Women', code: 'W'),
    );
    update.fold(
      (failure) => expect(failure, isA<GenderDuplicateFailure>()),
      (_) => fail('Expected duplicate failure'),
    );
  });

  test('23503 maps to in-use failure on delete', () async {
    final result = await repository.deleteGender(1);
    result.fold(
      (failure) => expect(failure, isA<GenderInUseFailure>()),
      (_) => fail('Expected in-use failure'),
    );
  });
}
