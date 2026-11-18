import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/access/models/access_snapshot.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';

abstract interface class AccessRepository {
  Future<Either<Failure, AccessSnapshot>> getMyAccess();
}
