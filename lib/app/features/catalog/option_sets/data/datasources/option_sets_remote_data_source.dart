import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/features/catalog/option_sets/data/models/option_set_model.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/entity/option_set_draft.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/entity/option_set_list_query.dart';

abstract interface class OptionSetsRemoteDataSource {
  Future<ApiResult<PaginatedResult<OptionSetModel>>> getOptionSets(OptionSetListQuery query);
  Future<ApiResult<OptionSetModel>> createOptionSet(OptionSetDraft draft);
  Future<ApiResult<OptionSetModel>> updateOptionSet({required int id, required OptionSetDraft draft});
  Future<ApiResult<Unit>> setOptionSetActive({required int id, required bool isActive});
  Future<ApiResult<Unit>> createOption({required int optionSetId, required CatalogOptionDraft draft});
  Future<ApiResult<Unit>> updateOption({required int optionId, required CatalogOptionDraft draft});
  Future<ApiResult<Unit>> setOptionActive({required int optionId, required bool isActive});
}
