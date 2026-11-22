import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/base/use_case.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/repositories/colors_repository.dart';

class DeleteColorParams extends Equatable {
  const DeleteColorParams(this.id);

  final int id;

  @override
  List<Object?> get props => [id];
}

class DeleteColorUseCase extends UseCase<Unit, DeleteColorParams> {
  DeleteColorUseCase(this._repository);

  final ColorsRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(DeleteColorParams params) =>
      _repository.deleteColor(params.id);
}
