import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/base/use_case.dart';
import 'package:accounting_software/app/features/auth/domain/repositories/auth_repository.dart';

class GetMustChangePasswordUseCase
    extends UseCase<bool, GetMustChangePasswordParams> {
  GetMustChangePasswordUseCase(this._repository);
  final AuthRepository _repository;

  @override
  Future<Either<Failure, bool>> call(GetMustChangePasswordParams params) =>
      _repository.getMustChangePassword(userId: params.userId);
}

class GetMustChangePasswordParams extends Equatable {
  const GetMustChangePasswordParams({required this.userId});
  final String userId;
  @override
  List<Object?> get props => [userId];
}
