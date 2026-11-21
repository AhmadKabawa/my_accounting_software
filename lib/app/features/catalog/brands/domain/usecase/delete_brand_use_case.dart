import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/base/use_case.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/repositories/brands_repository.dart';

class DeleteBrandUseCase extends UseCase<Unit, int> {
  DeleteBrandUseCase(this._repository);
  final BrandsRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(int id) => _repository.deleteBrand(id);
}
