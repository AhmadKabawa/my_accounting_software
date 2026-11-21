import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';

/// Base class for all use cases
/// [ResultType] is the return type
/// [Params] is the parameters type
abstract class UseCase<ResultType, Params> {
  Future<Either<Failure, ResultType>> call(Params params);
}

/// Used when a use case doesn't need parameters
class NoParams extends Equatable {
  @override
  List<Object> get props => [];
}
