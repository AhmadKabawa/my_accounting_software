import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/base/use_case.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/features/catalog/age_groups/domain/entity/age_group.dart';
import 'package:accounting_software/app/features/catalog/age_groups/domain/entity/age_group_draft.dart';
import 'package:accounting_software/app/features/catalog/age_groups/domain/entity/age_group_list_query.dart';
import 'package:accounting_software/app/features/catalog/age_groups/domain/repositories/age_groups_repository.dart';
class GetAgeGroupsUseCase extends UseCase<PaginatedResult<AgeGroup>, AgeGroupListQuery> {
  GetAgeGroupsUseCase(this._r); final AgeGroupsRepository _r;
  @override Future<Either<Failure, PaginatedResult<AgeGroup>>> call(AgeGroupListQuery p) => _r.getAgeGroups(p);
}
class CreateAgeGroupUseCase extends UseCase<AgeGroup, AgeGroupDraft> {
  CreateAgeGroupUseCase(this._r); final AgeGroupsRepository _r;
  @override Future<Either<Failure, AgeGroup>> call(AgeGroupDraft p) => _r.createAgeGroup(p);
}
class UpdateAgeGroupParams { const UpdateAgeGroupParams({required this.id, required this.draft}); final int id; final AgeGroupDraft draft; }
class UpdateAgeGroupUseCase extends UseCase<AgeGroup, UpdateAgeGroupParams> {
  UpdateAgeGroupUseCase(this._r); final AgeGroupsRepository _r;
  @override Future<Either<Failure, AgeGroup>> call(UpdateAgeGroupParams p) => _r.updateAgeGroup(id: p.id, draft: p.draft);
}
class DeleteAgeGroupUseCase extends UseCase<Unit, int> {
  DeleteAgeGroupUseCase(this._r); final AgeGroupsRepository _r;
  @override Future<Either<Failure, Unit>> call(int p) => _r.deleteAgeGroup(p);
}
class SetAgeGroupActiveParams { const SetAgeGroupActiveParams({required this.id, required this.isActive}); final int id; final bool isActive; }
class SetAgeGroupActiveUseCase extends UseCase<Unit, SetAgeGroupActiveParams> {
  SetAgeGroupActiveUseCase(this._r); final AgeGroupsRepository _r;
  @override Future<Either<Failure, Unit>> call(SetAgeGroupActiveParams p) => _r.setAgeGroupActive(id: p.id, isActive: p.isActive);
}
