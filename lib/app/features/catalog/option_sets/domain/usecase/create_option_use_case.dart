import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/base/use_case.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/entity/option_set_draft.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/repositories/option_sets_repository.dart';

class CreateOptionParams {
  const CreateOptionParams({required this.optionSetId, required this.draft});
  final int optionSetId;
  final CatalogOptionDraft draft;
}

class CreateOptionUseCase extends UseCase<Unit, CreateOptionParams> {
  CreateOptionUseCase(this._repository);
  final OptionSetsRepository _repository;
  @override
  Future<Either<Failure, Unit>> call(CreateOptionParams params) => _repository
      .createOption(optionSetId: params.optionSetId, draft: params.draft);
}
