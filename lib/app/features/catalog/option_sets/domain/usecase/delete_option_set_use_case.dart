import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/base/use_case.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/repositories/option_sets_repository.dart';

class DeleteOptionSetUseCase extends UseCase<Unit, int> {
  DeleteOptionSetUseCase(this._repository);
  final OptionSetsRepository _repository;
  @override
  Future<Either<Failure, Unit>> call(int id) => _repository.deleteOptionSet(id);
}
