import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/features/catalog/size_systems/systems/domain/entity/size_system.dart';
import 'package:accounting_software/app/features/catalog/size_systems/systems/domain/entity/size_system_draft.dart';
import 'package:accounting_software/app/features/catalog/size_systems/systems/domain/entity/size_system_list_query.dart';
import 'package:accounting_software/app/features/catalog/size_systems/systems/domain/entity/size_system_stats.dart';

abstract class SizeSystemsRepository {
  Future<Either<Failure, PaginatedResult<SizeSystem>>> getSizeSystems(
    SizeSystemListQuery query,
  );
  Future<Either<Failure, SizeSystemStats>> getStats();
  Future<Either<Failure, SizeSystem>> createSizeSystem(SizeSystemDraft draft);
  Future<Either<Failure, SizeSystem>> updateSizeSystem({
    required int id,
    required SizeSystemDraft draft,
  });
  Future<Either<Failure, Unit>> deleteSizeSystem(int id);
  Future<Either<Failure, Unit>> setSizeSystemActive({
    required int id,
    required bool isActive,
  });
}
