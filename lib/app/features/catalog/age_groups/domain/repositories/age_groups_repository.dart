import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/features/catalog/age_groups/domain/entity/age_group.dart';
import 'package:accounting_software/app/features/catalog/age_groups/domain/entity/age_group_draft.dart';
import 'package:accounting_software/app/features/catalog/age_groups/domain/entity/age_group_list_query.dart';

abstract interface class AgeGroupsRepository {
  Future<Either<Failure, PaginatedResult<AgeGroup>>> getAgeGroups(
    AgeGroupListQuery query,
  );
  Future<Either<Failure, AgeGroup>> createAgeGroup(AgeGroupDraft draft);
  Future<Either<Failure, AgeGroup>> updateAgeGroup({
    required int id,
    required AgeGroupDraft draft,
  });
  Future<Either<Failure, Unit>> deleteAgeGroup(int id);
  Future<Either<Failure, Unit>> setAgeGroupActive({
    required int id,
    required bool isActive,
  });
}
