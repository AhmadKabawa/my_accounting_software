import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/features/catalog/units/data/models/unit_model.dart';
import 'package:accounting_software/app/features/catalog/units/domain/entity/unit_draft.dart';
import 'package:accounting_software/app/features/catalog/units/domain/entity/unit_list_query.dart';

abstract interface class UnitsRemoteDataSource {
  Future<ApiResult<PaginatedResult<UnitModel>>> getUnits(UnitListQuery query);
  Future<ApiResult<UnitModel>> createUnit(UnitDraft draft);
  Future<ApiResult<UnitModel>> updateUnit({required int id, required UnitDraft draft});
  Future<ApiResult<Unit>> setUnitActive({required int id, required bool isActive});
  Future<ApiResult<Unit>> deleteUnit(int id);
}
