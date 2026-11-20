import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/base/use_case.dart';
import 'package:accounting_software/app/features/auth/domain/repositories/auth_repository.dart';

class ForceChangePasswordUseCase
    extends UseCase<Unit, ForceChangePasswordParams> {
  ForceChangePasswordUseCase(this._repository);
  final AuthRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(ForceChangePasswordParams params) =>
      _repository.forceChangePassword(newPassword: params.newPassword);
}

class ForceChangePasswordParams extends Equatable {
  const ForceChangePasswordParams({required this.newPassword});
  final String newPassword;
  @override
  List<Object?> get props => [newPassword];
}
