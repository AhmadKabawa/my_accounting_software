import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/base/use_case.dart';
import 'package:accounting_software/app/features/catalog/tags/domain/repositories/tags_repository.dart';

class DeleteTagParams extends Equatable {
  const DeleteTagParams(this.id);

  final int id;

  @override
  List<Object?> get props => [id];
}

class DeleteTagUseCase extends UseCase<Unit, DeleteTagParams> {
  DeleteTagUseCase(this._repository);

  final TagsRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(DeleteTagParams params) =>
      _repository.deleteTag(params.id);
}
