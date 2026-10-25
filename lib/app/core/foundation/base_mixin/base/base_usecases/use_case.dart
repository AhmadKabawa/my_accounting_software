import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:accounting_software/app/core/error/error_handling/failure/failure.dart';

/// Base class for all use cases
/// [Type] is the return type
/// [Params] is the parameters type
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Used when a use case doesn't need parameters
class NoParams extends Equatable {
  @override
  List<Object> get props => [];
}
