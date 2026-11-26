import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/base/use_case.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/entity/option_set.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/entity/option_set_draft.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/repositories/option_sets_repository.dart';

class CreateOptionSetUseCase extends UseCase<OptionSet, OptionSetDraft> {
  CreateOptionSetUseCase(this._repository);
  final OptionSetsRepository _repository;
  @override
  Future<Either<Failure, OptionSet>> call(OptionSetDraft params) =>
      _repository.createOptionSet(params);
}
