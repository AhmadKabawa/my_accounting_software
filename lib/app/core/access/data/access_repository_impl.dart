import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/access/data/access_remote_data_source.dart';
import 'package:accounting_software/app/core/access/domain/access_repository.dart';
import 'package:accounting_software/app/core/access/models/access_snapshot.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/base/repository_executor.dart';
import 'package:accounting_software/app/core/foundation/types/api_result.dart';

class AccessRepositoryImpl with RepositoryExecutor implements AccessRepository {
  const AccessRepositoryImpl({required AccessRemoteDataSource remote})
    : _remote = remote;

  final AccessRemoteDataSource _remote;

  @override
  Future<Either<Failure, AccessSnapshot>> getMyAccess() => execute(() async {
    final result = await _remote.getMyAccess();
    return result.toEither();
  });
}
