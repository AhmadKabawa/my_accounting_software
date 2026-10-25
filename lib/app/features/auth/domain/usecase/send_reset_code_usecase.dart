import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:accounting_software/app/core/error/error_handling/failure/failure.dart';
import 'package:accounting_software/app/core/foundation/base_mixin/base/base_usecases/use_case.dart';
import 'package:accounting_software/app/features/auth/domain/repositories/auth_repository.dart';

// ==================== 5. SendResetCodeUseCase ====================
class SendResetCodeUseCase extends UseCase<Unit, SendResetCodeParams> {
  final AuthRepository repository;

  SendResetCodeUseCase({required this.repository});

  @override
  Future<Either<Failure, Unit>> call(SendResetCodeParams params) async {
    return repository.sendResetCode(email: params.email);
  }
}

class SendResetCodeParams extends Equatable {
  final String email;

  const SendResetCodeParams({required this.email});

  @override
  List<Object?> get props => [email];
}
