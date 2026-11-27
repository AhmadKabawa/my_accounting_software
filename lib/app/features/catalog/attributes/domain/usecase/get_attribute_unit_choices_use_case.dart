import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/base/use_case.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/entity/attribute_lookup_choices.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/repositories/attributes_repository.dart';
class GetAttributeUnitChoicesUseCase extends UseCase<List<AttributeUnitChoice>, NoParams> {
  GetAttributeUnitChoicesUseCase(this._repository);
  final AttributesRepository _repository;
  @override
  Future<Either<Failure, List<AttributeUnitChoice>>> call(NoParams params) => _repository.getUnitChoices();
}