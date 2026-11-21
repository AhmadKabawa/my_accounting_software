import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/base/use_case.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/entity/catalog_color.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/entity/catalog_color_draft.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/repositories/colors_repository.dart';

class CreateColorUseCase extends UseCase<CatalogColor, CatalogColorDraft> {
  CreateColorUseCase(this._repository);
  final ColorsRepository _repository;

  @override
  Future<Either<Failure, CatalogColor>> call(CatalogColorDraft params) =>
      _repository.createColor(params);
}
