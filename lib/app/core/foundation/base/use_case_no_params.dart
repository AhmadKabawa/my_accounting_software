// ✅ UseCase بدون params
import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/error_handling/failure/failure.dart';

abstract class UseCaseNoParams<Output> {
  const UseCaseNoParams();
  Future<Either<Failure, Output>> call();
}
