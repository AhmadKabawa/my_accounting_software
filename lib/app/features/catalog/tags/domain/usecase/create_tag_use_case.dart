import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/base/use_case.dart';
import 'package:accounting_software/app/features/catalog/tags/domain/entity/catalog_tag.dart';
import 'package:accounting_software/app/features/catalog/tags/domain/entity/catalog_tag_draft.dart';
import 'package:accounting_software/app/features/catalog/tags/domain/repositories/tags_repository.dart';

class CreateTagUseCase extends UseCase<CatalogTag, CatalogTagDraft> {
  CreateTagUseCase(this._repository);
  final TagsRepository _repository;

  @override
  Future<Either<Failure, CatalogTag>> call(CatalogTagDraft params) =>
      _repository.createTag(params);
}
