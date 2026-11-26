import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/entity/option_set.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/entity/option_set_draft.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/entity/option_set_list_query.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/entity/option_set_stats.dart';

abstract interface class OptionSetsRepository {
  Future<Either<Failure, OptionSetStats>> getOptionSetStats();
  Future<Either<Failure, PaginatedResult<OptionSet>>> getOptionSets(OptionSetListQuery query);
  Future<Either<Failure, List<CatalogOption>>> getOptions({required int optionSetId, String search = ''});
  Future<Either<Failure, OptionSet>> createOptionSet(OptionSetDraft draft);
  Future<Either<Failure, OptionSet>> updateOptionSet({required int id, required OptionSetDraft draft});
  Future<Either<Failure, Unit>> deleteOptionSet(int id);
  Future<Either<Failure, Unit>> setOptionSetActive({required int id, required bool isActive});
  Future<Either<Failure, Unit>> createOption({required int optionSetId, required CatalogOptionDraft draft});
  Future<Either<Failure, Unit>> updateOption({required int optionId, required CatalogOptionDraft draft});
  Future<Either<Failure, Unit>> setOptionActive({required int optionId, required bool isActive});
}
