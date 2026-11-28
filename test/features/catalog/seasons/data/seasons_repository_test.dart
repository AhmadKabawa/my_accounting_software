import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/error/exceptions/api_exception.dart';
import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/features/catalog/seasons/data/datasources/seasons_remote_data_source.dart';
import 'package:accounting_software/app/features/catalog/seasons/data/models/season_model.dart';
import 'package:accounting_software/app/features/catalog/seasons/data/repositories/seasons_repository_impl.dart';
import 'package:accounting_software/app/features/catalog/seasons/domain/entity/season_draft.dart';
import 'package:accounting_software/app/features/catalog/seasons/domain/entity/season_list_query.dart';
import 'package:accounting_software/app/features/catalog/seasons/domain/failures/season_failures.dart';

class _FakeSeasonsRemote implements SeasonsRemoteDataSource {
  ApiResult<SeasonModel> createResult = const ApiSuccess(
    SeasonModel(id: 1, name: 'Summer', code: 'SUM', isActive: true),
  );
  ApiResult<Unit> deleteResult = const ApiSuccess(unit);

  @override
  Future<ApiResult<PaginatedResult<SeasonModel>>> getSeasons(
    SeasonListQuery query,
  ) async => const ApiSuccess(
    PaginatedResult(items: [], totalCount: 0, currentPage: 1, totalPages: 0),
  );

  @override
  Future<ApiResult<SeasonModel>> createSeason(SeasonDraft draft) async =>
      createResult;

  @override
  Future<ApiResult<SeasonModel>> updateSeason({
    required int id,
    required SeasonDraft draft,
  }) async => createResult;

  @override
  Future<ApiResult<Unit>> deleteSeason(int id) async => deleteResult;

  @override
  Future<ApiResult<Unit>> setSeasonActive({
    required int id,
    required bool isActive,
  }) async => const ApiSuccess(unit);
}

void main() {
  group('SeasonsRepositoryImpl', () {
    test('maps unique code conflict to duplicate failure', () async {
      final remote = _FakeSeasonsRemote()
        ..createResult = ApiFailure(ApiException.conflict(errorCode: '23505'));
      final result = await SeasonsRepositoryImpl(
        remote,
      ).createSeason(const SeasonDraft(name: 'Summer', code: 'SUM'));
      expect(
        result.fold((failure) => failure, (_) => null),
        isA<SeasonDuplicateFailure>(),
      );
    });

    test('maps foreign key delete rejection to in-use failure', () async {
      final remote = _FakeSeasonsRemote()
        ..deleteResult = ApiFailure(ApiException.conflict(errorCode: '23503'));
      final result = await SeasonsRepositoryImpl(remote).deleteSeason(1);
      expect(
        result.fold((failure) => failure, (_) => null),
        isA<SeasonInUseFailure>(),
      );
    });
  });
}
