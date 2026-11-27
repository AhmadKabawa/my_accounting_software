import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/base/use_case.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/repositories/attributes_repository.dart';
class DeleteAttributeUseCase extends UseCase<Unit, int> {
  DeleteAttributeUseCase(this._repository);
  final AttributesRepository _repository;
  @override
  Future<Either<Failure, Unit>> call(int id) => _repository.deleteAttribute(id);
}