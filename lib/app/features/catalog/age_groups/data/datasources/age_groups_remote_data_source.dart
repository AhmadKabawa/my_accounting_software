import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/features/catalog/age_groups/data/models/age_group_model.dart';
import 'package:accounting_software/app/features/catalog/age_groups/domain/entity/age_group_draft.dart';
import 'package:accounting_software/app/features/catalog/age_groups/domain/entity/age_group_list_query.dart';

abstract interface class AgeGroupsRemoteDataSource {
  Future<ApiResult<PaginatedResult<AgeGroupModel>>> getAgeGroups(
    AgeGroupListQuery query,
  );
  Future<ApiResult<AgeGroupModel>> createAgeGroup(AgeGroupDraft draft);
  Future<ApiResult<AgeGroupModel>> updateAgeGroup({
    required int id,
    required AgeGroupDraft draft,
  });
  Future<ApiResult<Unit>> deleteAgeGroup(int id);
  Future<ApiResult<Unit>> setAgeGroupActive({
    required int id,
    required bool isActive,
  });
}
