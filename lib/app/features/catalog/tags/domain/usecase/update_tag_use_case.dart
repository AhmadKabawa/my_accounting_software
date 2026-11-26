import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/base/use_case.dart';
import 'package:accounting_software/app/features/catalog/tags/domain/entity/catalog_tag.dart';
import 'package:accounting_software/app/features/catalog/tags/domain/entity/catalog_tag_draft.dart';
import 'package:accounting_software/app/features/catalog/tags/domain/repositories/tags_repository.dart';

class UpdateTagParams extends Equatable {
  const UpdateTagParams({required this.id, required this.draft});
  final int id;
  final CatalogTagDraft draft;

  @override
  List<Object?> get props => [id, draft];
}

class UpdateTagUseCase extends UseCase<CatalogTag, UpdateTagParams> {
  UpdateTagUseCase(this._repository);
  final TagsRepository _repository;

  @override
  Future<Either<Failure, CatalogTag>> call(UpdateTagParams params) =>
      _repository.updateTag(id: params.id, draft: params.draft);
}
