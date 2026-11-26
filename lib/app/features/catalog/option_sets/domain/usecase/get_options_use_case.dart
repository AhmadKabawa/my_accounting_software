import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/base/use_case.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/entity/option_set.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/repositories/option_sets_repository.dart';

class GetOptionsParams {
  const GetOptionsParams({required this.optionSetId, this.search = ''});
  final int optionSetId;
  final String search;
}

class GetOptionsUseCase extends UseCase<List<CatalogOption>, GetOptionsParams> {
  GetOptionsUseCase(this._repository);
  final OptionSetsRepository _repository;
  @override
  Future<Either<Failure, List<CatalogOption>>> call(GetOptionsParams params) =>
      _repository.getOptions(
        optionSetId: params.optionSetId,
        search: params.search,
      );
}
