import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/base/use_case.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/repositories/option_sets_repository.dart';

class SetOptionSetActiveParams {
  const SetOptionSetActiveParams({required this.id, required this.isActive});
  final int id;
  final bool isActive;
}

class SetOptionSetActiveUseCase
    extends UseCase<Unit, SetOptionSetActiveParams> {
  SetOptionSetActiveUseCase(this._repository);
  final OptionSetsRepository _repository;
  @override
  Future<Either<Failure, Unit>> call(SetOptionSetActiveParams params) =>
      _repository.setOptionSetActive(id: params.id, isActive: params.isActive);
}
