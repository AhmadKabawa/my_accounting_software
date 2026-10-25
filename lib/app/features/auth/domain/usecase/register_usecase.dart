import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:accounting_software/app/core/error/error_handling/failure/failure.dart';
import 'package:accounting_software/app/core/foundation/base_mixin/base/base_usecases/use_case.dart';
import 'package:accounting_software/app/features/auth/domain/entity/auth_result/auth_result.dart';
import 'package:accounting_software/app/features/auth/domain/repositories/auth_repository.dart';

// ==================== 2. RegisterUseCase ====================
class RegisterUseCase extends UseCase<AuthResultEntity, RegisterParams> {
  final AuthRepository repository;

  RegisterUseCase({required this.repository});

  @override
  Future<Either<Failure, AuthResultEntity>> call(RegisterParams params) async {
    return repository.register(
      email: params.email,
      password: params.password,
      name: params.name,
      phone: params.phone,
    );
  }
}

class RegisterParams extends Equatable {
  final String email;
  final String password;
  final String name;
  final String? phone;

  const RegisterParams({
    required this.email,
    required this.password,
    required this.name,
    this.phone,
  });
  @override
  List<Object?> get props => [email, password, name, phone];
}
