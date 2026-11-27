import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/base/use_case.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/entity/attribute_lookup_choices.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/repositories/attributes_repository.dart';
class GetAttributeOptionSetChoicesUseCase extends UseCase<List<AttributeOptionSetChoice>, NoParams> {
  GetAttributeOptionSetChoicesUseCase(this._repository);
  final AttributesRepository _repository;
  @override
  Future<Either<Failure, List<AttributeOptionSetChoice>>> call(NoParams params) => _repository.getOptionSetChoices();
}