import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/access/domain/access_repository.dart';
import 'package:accounting_software/app/core/access/models/access_snapshot.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/base/use_case.dart';

class GetMyAccessUseCase extends UseCase<AccessSnapshot, NoParams> {
  GetMyAccessUseCase(this._repository);
  final AccessRepository _repository;

  @override
  Future<Either<Failure, AccessSnapshot>> call(NoParams params) =>
      _repository.getMyAccess();
}
