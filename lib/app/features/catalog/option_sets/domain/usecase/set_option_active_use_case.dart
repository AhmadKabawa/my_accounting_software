import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/base/use_case.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/repositories/option_sets_repository.dart';

class SetOptionActiveParams {
  const SetOptionActiveParams({required this.optionId, required this.isActive});
  final int optionId;
  final bool isActive;
}

class SetOptionActiveUseCase extends UseCase<Unit, SetOptionActiveParams> {
  SetOptionActiveUseCase(this._repository);
  final OptionSetsRepository _repository;
  @override
  Future<Either<Failure, Unit>> call(SetOptionActiveParams params) =>
      _repository.setOptionActive(
        optionId: params.optionId,
        isActive: params.isActive,
      );
}
