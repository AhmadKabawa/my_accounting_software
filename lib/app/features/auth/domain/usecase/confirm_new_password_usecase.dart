import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:accounting_software/app/core/error/error_handling/failure/failure.dart';
import 'package:accounting_software/app/core/foundation/base_mixin/base/base_usecases/use_case.dart';
import 'package:accounting_software/app/features/auth/domain/repositories/auth_repository.dart';

// ==================== 7. ConfirmNewPasswordUseCase ====================
class ConfirmNewPasswordUseCase
    extends UseCase<Unit, ConfirmNewPasswordParams> {
  final AuthRepository repository;

  ConfirmNewPasswordUseCase({required this.repository});

  @override
  Future<Either<Failure, Unit>> call(ConfirmNewPasswordParams params) async {
    return repository.confirmNewPassword(
      email: params.email,
      code: params.code,
      newPassword: params.newPassword,
    );
  }
}

class ConfirmNewPasswordParams extends Equatable {
  final String email;
  final String code;
  final String newPassword;

  const ConfirmNewPasswordParams({
    required this.email,
    required this.code,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [email, code, newPassword];
}
