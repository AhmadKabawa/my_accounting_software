import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/base/use_case.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/entity/option_set_draft.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/repositories/option_sets_repository.dart';

class UpdateOptionParams {
  const UpdateOptionParams({required this.optionId, required this.draft});
  final int optionId;
  final CatalogOptionDraft draft;
}
class UpdateOptionUseCase extends UseCase<Unit, UpdateOptionParams> {
  UpdateOptionUseCase(this._repository);
  final OptionSetsRepository _repository;
  @override
  Future<Either<Failure, Unit>> call(UpdateOptionParams params) =>
      _repository.updateOption(optionId: params.optionId, draft: params.draft);
}
