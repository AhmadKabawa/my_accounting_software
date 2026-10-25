import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:accounting_software/app/core/error/error_handling/failure/failure.dart';
import 'package:accounting_software/app/core/foundation/base_mixin/base/base_usecases/use_case.dart';
import 'package:accounting_software/app/features/auth/domain/repositories/auth_repository.dart';

// ==================== 6. VerifyResetCodeUseCase ====================
class VerifyResetCodeUseCase extends UseCase<Unit, VerifyResetCodeParams> {
  final AuthRepository repository;

  VerifyResetCodeUseCase({required this.repository});

  @override
  Future<Either<Failure, Unit>> call(VerifyResetCodeParams params) async {
    return repository.verifyResetCode(email: params.email, code: params.code);
  }
}

class VerifyResetCodeParams extends Equatable {
  final String email;
  final String code;

  const VerifyResetCodeParams({required this.email, required this.code});

  @override
  List<Object?> get props => [email, code];
}
