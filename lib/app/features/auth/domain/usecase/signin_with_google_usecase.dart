// ==================== 3. SignInWithGoogleUseCase ====================
import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/error_handling/failure/failure.dart';
import 'package:accounting_software/app/core/foundation/base_mixin/base/base_usecases/use_case.dart';
import 'package:accounting_software/app/features/auth/domain/entity/auth_result/auth_result.dart';
import 'package:accounting_software/app/features/auth/domain/repositories/auth_repository.dart';

class SignInWithGoogleUseCase extends UseCase<AuthResultEntity, NoParams> {
  final AuthRepository repository;

  SignInWithGoogleUseCase({required this.repository});

  @override
  Future<Either<Failure, AuthResultEntity>> call(NoParams params) async {
    return repository.signInWithGoogle();
  }
}
