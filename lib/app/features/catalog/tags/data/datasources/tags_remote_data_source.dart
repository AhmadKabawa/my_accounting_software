import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/features/catalog/tags/data/models/tag_model.dart';
import 'package:accounting_software/app/features/catalog/tags/domain/entity/catalog_tag_draft.dart';
import 'package:accounting_software/app/features/catalog/tags/domain/entity/tag_list_query.dart';

abstract interface class TagsRemoteDataSource {
  Future<ApiResult<PaginatedResult<TagModel>>> getTags(TagListQuery query);

  Future<ApiResult<TagModel>> createTag(CatalogTagDraft draft);

  Future<ApiResult<TagModel>> updateTag({
    required int id,
    required CatalogTagDraft draft,
  });

  Future<ApiResult<Unit>> deleteTag(int id);

  Future<ApiResult<Unit>> setTagActive({
    required int id,
    required bool isActive,
  });
}
