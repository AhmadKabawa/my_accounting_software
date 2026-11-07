import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/base/use_case.dart';
import 'package:accounting_software/app/features/home/domain/entity/home_summary.dart';
import 'package:accounting_software/app/features/home/domain/repository/home_repository.dart';

class GetHomeSummaryUseCase implements UseCase<HomeSummary, NoParams> {
  const GetHomeSummaryUseCase(this._repository);

  final HomeRepository _repository;

  @override
  Future<Either<Failure, HomeSummary>> call(NoParams params) =>
      _repository.getSummary();
}
