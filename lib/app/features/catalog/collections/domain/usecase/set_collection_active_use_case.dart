import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/base/use_case.dart';
import 'package:accounting_software/app/features/catalog/collections/domain/repositories/collections_repository.dart';

class SetCollectionActiveParams {
  const SetCollectionActiveParams({required this.id, required this.isActive});
  final int id;
  final bool isActive;
}

class SetCollectionActiveUseCase
    extends UseCase<Unit, SetCollectionActiveParams> {
  SetCollectionActiveUseCase(this._r);
  final CollectionsRepository _r;
  @override
  Future<Either<Failure, Unit>> call(SetCollectionActiveParams p) =>
      _r.setCollectionActive(id: p.id, isActive: p.isActive);
}
