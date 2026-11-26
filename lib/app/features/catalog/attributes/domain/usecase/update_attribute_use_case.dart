import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/base/use_case.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/entity/attribute_draft.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/entity/catalog_attribute.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/repositories/attributes_repository.dart';
class UpdateAttributeParams { const UpdateAttributeParams({required this.id, required this.draft}); final int id; final AttributeDraft draft; }
class UpdateAttributeUseCase extends UseCase<CatalogAttribute, UpdateAttributeParams> {
  UpdateAttributeUseCase(this._repository);
  final AttributesRepository _repository;
  @override
  Future<Either<Failure, CatalogAttribute>> call(UpdateAttributeParams params) => _repository.updateAttribute(id: params.id, draft: params.draft);
}
