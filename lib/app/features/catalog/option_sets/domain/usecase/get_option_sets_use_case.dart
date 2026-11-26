import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/base/use_case.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/entity/option_set.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/entity/option_set_list_query.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/repositories/option_sets_repository.dart';
class GetOptionSetsUseCase extends UseCase<PaginatedResult<OptionSet>, OptionSetListQuery> {
  GetOptionSetsUseCase(this._repository);
  final OptionSetsRepository _repository;
  @override
  Future<Either<Failure, PaginatedResult<OptionSet>>> call(OptionSetListQuery params) => _repository.getOptionSets(params);
}
