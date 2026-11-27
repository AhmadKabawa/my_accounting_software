import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/base/use_case.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/features/catalog/size_systems/groups/domain/entity/gender_option.dart';
import 'package:accounting_software/app/features/catalog/size_systems/groups/domain/entity/size_group.dart';
import 'package:accounting_software/app/features/catalog/size_systems/groups/domain/entity/size_group_draft.dart';
import 'package:accounting_software/app/features/catalog/size_systems/groups/domain/entity/size_group_list_query.dart';
import 'package:accounting_software/app/features/catalog/size_systems/groups/domain/repositories/size_groups_repository.dart';

class GetSizeGroupsUseCase
    extends UseCase<PaginatedResult<SizeGroup>, SizeGroupListQuery> {
  GetSizeGroupsUseCase(this._repository);
  final SizeGroupsRepository _repository;

  @override
  Future<Either<Failure, PaginatedResult<SizeGroup>>> call(
    SizeGroupListQuery params,
  ) => _repository.getSizeGroups(params);
}

class GetGenderOptionsUseCase extends UseCase<List<GenderOption>, NoParams> {
  GetGenderOptionsUseCase(this._repository);
  final SizeGroupsRepository _repository;

  @override
  Future<Either<Failure, List<GenderOption>>> call(NoParams params) =>
      _repository.getGenders();
}

class CreateSizeGroupUseCase extends UseCase<SizeGroup, SizeGroupDraft> {
  CreateSizeGroupUseCase(this._repository);
  final SizeGroupsRepository _repository;

  @override
  Future<Either<Failure, SizeGroup>> call(SizeGroupDraft params) =>
      _repository.createSizeGroup(params);
}

class UpdateSizeGroupParams extends Equatable {
  const UpdateSizeGroupParams({required this.id, required this.draft});
  final int id;
  final SizeGroupDraft draft;

  @override
  List<Object?> get props => [id, draft];
}

class UpdateSizeGroupUseCase extends UseCase<SizeGroup, UpdateSizeGroupParams> {
  UpdateSizeGroupUseCase(this._repository);
  final SizeGroupsRepository _repository;

  @override
  Future<Either<Failure, SizeGroup>> call(UpdateSizeGroupParams params) =>
      _repository.updateSizeGroup(id: params.id, draft: params.draft);
}

class DeleteSizeGroupUseCase extends UseCase<Unit, int> {
  DeleteSizeGroupUseCase(this._repository);
  final SizeGroupsRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(int params) =>
      _repository.deleteSizeGroup(params);
}

class SetSizeGroupActiveParams extends Equatable {
  const SetSizeGroupActiveParams({required this.id, required this.isActive});
  final int id;
  final bool isActive;

  @override
  List<Object?> get props => [id, isActive];
}

class SetSizeGroupActiveUseCase
    extends UseCase<Unit, SetSizeGroupActiveParams> {
  SetSizeGroupActiveUseCase(this._repository);
  final SizeGroupsRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(SetSizeGroupActiveParams params) =>
      _repository.setSizeGroupActive(id: params.id, isActive: params.isActive);
}
