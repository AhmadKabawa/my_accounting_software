import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/error_handling/failure/failure.dart';
import 'package:accounting_software/app/core/foundation/base_mixin/base/base_usecases/use_case.dart';
import 'package:accounting_software/app/features/auth/domain/repositories/auth_repository.dart';

// ==================== 4. LogoutUseCase ====================
class LogoutUseCase extends UseCase<Unit, NoParams> {
  final AuthRepository repository;

  LogoutUseCase({required this.repository});

  @override
  Future<Either<Failure, Unit>> call(NoParams params) async {
    return repository.logout();
  }
}
