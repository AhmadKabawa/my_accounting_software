import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/features/catalog/size_systems/groups/domain/entity/gender_option.dart';
import 'package:accounting_software/app/features/catalog/size_systems/groups/domain/entity/size_group.dart';
import 'package:accounting_software/app/features/catalog/size_systems/groups/domain/entity/size_group_draft.dart';
import 'package:accounting_software/app/features/catalog/size_systems/groups/domain/entity/size_group_list_query.dart';

abstract class SizeGroupsRepository {
  Future<Either<Failure, PaginatedResult<SizeGroup>>> getSizeGroups(
    SizeGroupListQuery query,
  );
  Future<Either<Failure, SizeGroup>> createSizeGroup(SizeGroupDraft draft);
  Future<Either<Failure, SizeGroup>> updateSizeGroup({
    required int id,
    required SizeGroupDraft draft,
  });
  Future<Either<Failure, Unit>> deleteSizeGroup(int id);
  Future<Either<Failure, Unit>> setSizeGroupActive({
    required int id,
    required bool isActive,
  });

  /// Read-only genders for the picker/filter. May legitimately be empty.
  Future<Either<Failure, List<GenderOption>>> getGenders();
}
