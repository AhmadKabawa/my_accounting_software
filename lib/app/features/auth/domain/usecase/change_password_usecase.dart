import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:accounting_software/app/core/error/error_handling/failure/failure.dart';
import 'package:accounting_software/app/core/foundation/base_mixin/base/base_usecases/use_case.dart';
import 'package:accounting_software/app/features/auth/domain/repositories/auth_repository.dart';

// ==================== 9. ChangePasswordUseCase ====================
class ChangePasswordUseCase extends UseCase<Unit, ChangePasswordParams> {
  final AuthRepository repository;

  ChangePasswordUseCase({required this.repository});

  @override
  Future<Either<Failure, Unit>> call(ChangePasswordParams params) async {
    return repository.changePassword(
      currentPassword: params.currentPassword,
      newPassword: params.newPassword,
    );
  }
}

class ChangePasswordParams extends Equatable {
  final String currentPassword;
  final String newPassword;

  const ChangePasswordParams({
    required this.currentPassword,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [currentPassword, newPassword];
}
