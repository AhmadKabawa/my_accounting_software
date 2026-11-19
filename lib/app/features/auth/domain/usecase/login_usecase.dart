import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/base/use_case.dart';
import 'package:accounting_software/app/features/auth/domain/entity/auth_result/auth_result.dart';
import 'package:accounting_software/app/features/auth/domain/login_identifier.dart';
import 'package:accounting_software/app/features/auth/domain/repositories/auth_repository.dart';

/// Signs in with a username (or a full e-mail, see [resolveLoginEmail]).
class LoginUseCase extends UseCase<AuthResultEntity, LoginParams> {
  final AuthRepository repository;

  /// Domain appended to a plain username (`AppConfig.loginEmailDomain`).
  final String emailDomain;

  LoginUseCase({required this.repository, required this.emailDomain});

  @override
  Future<Either<Failure, AuthResultEntity>> call(LoginParams params) async {
    return repository.login(
      email: resolveLoginEmail(params.identifier, domain: emailDomain),
      password: params.password,
    );
  }
}

class LoginParams extends Equatable {
  /// What the person typed: a username, or a full e-mail.
  final String identifier;
  final String password;

  const LoginParams({required this.identifier, required this.password});

  @override
  List<Object?> get props => [identifier, password];
}
