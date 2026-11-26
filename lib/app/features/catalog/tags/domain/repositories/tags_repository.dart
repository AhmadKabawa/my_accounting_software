import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/features/catalog/tags/domain/entity/tag_stats.dart';
import 'package:accounting_software/app/features/catalog/tags/domain/entity/catalog_tag.dart';
import 'package:accounting_software/app/features/catalog/tags/domain/entity/catalog_tag_draft.dart';
import 'package:accounting_software/app/features/catalog/tags/domain/entity/tag_list_query.dart';

abstract interface class TagsRepository {
  Future<Either<Failure, TagStats>> getTagStats();

  Future<Either<Failure, Unit>> deleteTag(int id);

  Future<Either<Failure, PaginatedResult<CatalogTag>>> getTags(
    TagListQuery query,
  );

  Future<Either<Failure, CatalogTag>> createTag(CatalogTagDraft draft);

  Future<Either<Failure, CatalogTag>> updateTag({
    required int id,
    required CatalogTagDraft draft,
  });

  Future<Either<Failure, Unit>> setTagActive({
    required int id,
    required bool isActive,
  });
}
