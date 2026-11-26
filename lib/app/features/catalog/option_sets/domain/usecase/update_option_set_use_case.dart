import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/base/use_case.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/entity/option_set.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/entity/option_set_draft.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/repositories/option_sets_repository.dart';

class UpdateOptionSetParams {
  const UpdateOptionSetParams({required this.id, required this.draft});
  final int id;
  final OptionSetDraft draft;
}

class UpdateOptionSetUseCase extends UseCase<OptionSet, UpdateOptionSetParams> {
  UpdateOptionSetUseCase(this._repository);
  final OptionSetsRepository _repository;
  @override
  Future<Either<Failure, OptionSet>> call(UpdateOptionSetParams params) =>
      _repository.updateOptionSet(id: params.id, draft: params.draft);
}
