import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/features/home/domain/entity/home_summary.dart';

abstract interface class HomeRepository {
  Future<Either<Failure, HomeSummary>> getSummary();
}
