import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/features/catalog/size_systems/groups/data/models/size_group_model.dart';
import 'package:accounting_software/app/features/catalog/size_systems/groups/domain/entity/size_group_draft.dart';
import 'package:accounting_software/app/features/catalog/size_systems/groups/domain/entity/size_group_list_query.dart';

abstract class SizeGroupsRemoteDataSource {
  Future<ApiResult<PaginatedResult<SizeGroupModel>>> getSizeGroups(
    SizeGroupListQuery query,
  );
  Future<ApiResult<SizeGroupModel>> createSizeGroup(SizeGroupDraft draft);
  Future<ApiResult<SizeGroupModel>> updateSizeGroup({
    required int id,
    required SizeGroupDraft draft,
  });
  Future<ApiResult<Unit>> deleteSizeGroup(int id);
  Future<ApiResult<Unit>> setSizeGroupActive({
    required int id,
    required bool isActive,
  });
  Future<ApiResult<List<GenderOptionModel>>> getGenders();
}
