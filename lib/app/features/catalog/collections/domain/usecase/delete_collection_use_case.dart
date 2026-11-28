import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/base/use_case.dart';
import 'package:accounting_software/app/features/catalog/collections/domain/repositories/collections_repository.dart';

class DeleteCollectionParams {
  const DeleteCollectionParams(this.id);
  final int id;
}

class DeleteCollectionUseCase extends UseCase<Unit, DeleteCollectionParams> {
  DeleteCollectionUseCase(this._r);
  final CollectionsRepository _r;
  @override
  Future<Either<Failure, Unit>> call(DeleteCollectionParams p) =>
      _r.deleteCollection(p.id);
}
