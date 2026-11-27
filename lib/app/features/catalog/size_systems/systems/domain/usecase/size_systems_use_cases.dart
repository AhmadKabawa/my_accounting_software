import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/base/use_case.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/features/catalog/size_systems/systems/domain/entity/size_system.dart';
import 'package:accounting_software/app/features/catalog/size_systems/systems/domain/entity/size_system_draft.dart';
import 'package:accounting_software/app/features/catalog/size_systems/systems/domain/entity/size_system_list_query.dart';
import 'package:accounting_software/app/features/catalog/size_systems/systems/domain/entity/size_system_stats.dart';
import 'package:accounting_software/app/features/catalog/size_systems/systems/domain/repositories/size_systems_repository.dart';

class GetSizeSystemsUseCase
    extends UseCase<PaginatedResult<SizeSystem>, SizeSystemListQuery> {
  GetSizeSystemsUseCase(this._repository);
  final SizeSystemsRepository _repository;

  @override
  Future<Either<Failure, PaginatedResult<SizeSystem>>> call(
    SizeSystemListQuery params,
  ) => _repository.getSizeSystems(params);
}

class GetSizeSystemStatsUseCase extends UseCase<SizeSystemStats, NoParams> {
  GetSizeSystemStatsUseCase(this._repository);
  final SizeSystemsRepository _repository;

  @override
  Future<Either<Failure, SizeSystemStats>> call(NoParams params) =>
      _repository.getStats();
}

class CreateSizeSystemUseCase extends UseCase<SizeSystem, SizeSystemDraft> {
  CreateSizeSystemUseCase(this._repository);
  final SizeSystemsRepository _repository;

  @override
  Future<Either<Failure, SizeSystem>> call(SizeSystemDraft params) =>
      _repository.createSizeSystem(params);
}

class UpdateSizeSystemParams extends Equatable {
  const UpdateSizeSystemParams({required this.id, required this.draft});
  final int id;
  final SizeSystemDraft draft;

  @override
  List<Object?> get props => [id, draft];
}

class UpdateSizeSystemUseCase
    extends UseCase<SizeSystem, UpdateSizeSystemParams> {
  UpdateSizeSystemUseCase(this._repository);
  final SizeSystemsRepository _repository;

  @override
  Future<Either<Failure, SizeSystem>> call(UpdateSizeSystemParams params) =>
      _repository.updateSizeSystem(id: params.id, draft: params.draft);
}

class DeleteSizeSystemUseCase extends UseCase<Unit, int> {
  DeleteSizeSystemUseCase(this._repository);
  final SizeSystemsRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(int params) =>
      _repository.deleteSizeSystem(params);
}

class SetSizeSystemActiveParams extends Equatable {
  const SetSizeSystemActiveParams({required this.id, required this.isActive});
  final int id;
  final bool isActive;

  @override
  List<Object?> get props => [id, isActive];
}

class SetSizeSystemActiveUseCase
    extends UseCase<Unit, SetSizeSystemActiveParams> {
  SetSizeSystemActiveUseCase(this._repository);
  final SizeSystemsRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(SetSizeSystemActiveParams params) =>
      _repository.setSizeSystemActive(id: params.id, isActive: params.isActive);
}
