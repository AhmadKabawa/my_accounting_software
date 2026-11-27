import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/features/catalog/size_systems/systems/data/models/size_system_model.dart';
import 'package:accounting_software/app/features/catalog/size_systems/systems/domain/entity/size_system_draft.dart';
import 'package:accounting_software/app/features/catalog/size_systems/systems/domain/entity/size_system_list_query.dart';
import 'package:accounting_software/app/features/catalog/size_systems/systems/domain/entity/size_system_stats.dart';

abstract class SizeSystemsRemoteDataSource {
  Future<ApiResult<PaginatedResult<SizeSystemModel>>> getSizeSystems(
    SizeSystemListQuery query,
  );
  Future<ApiResult<SizeSystemStats>> getStats();
  Future<ApiResult<SizeSystemModel>> createSizeSystem(SizeSystemDraft draft);
  Future<ApiResult<SizeSystemModel>> updateSizeSystem({
    required int id,
    required SizeSystemDraft draft,
  });
  Future<ApiResult<Unit>> deleteSizeSystem(int id);
  Future<ApiResult<Unit>> setSizeSystemActive({
    required int id,
    required bool isActive,
  });
}
