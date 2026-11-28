import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/base/use_case.dart';
import 'package:accounting_software/app/features/catalog/materials/domain/repositories/materials_repository.dart';

class SetMaterialActiveParams {
  const SetMaterialActiveParams({required this.id, required this.isActive});
  final int id;
  final bool isActive;
}

class SetMaterialActiveUseCase extends UseCase<Unit, SetMaterialActiveParams> {
  SetMaterialActiveUseCase(this._r);
  final MaterialsRepository _r;
  @override
  Future<Either<Failure, Unit>> call(SetMaterialActiveParams p) =>
      _r.setMaterialActive(id: p.id, isActive: p.isActive);
}
