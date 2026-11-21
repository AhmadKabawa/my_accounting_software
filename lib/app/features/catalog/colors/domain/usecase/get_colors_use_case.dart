import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/base/use_case.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/entity/catalog_color.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/entity/color_list_query.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/repositories/colors_repository.dart';

class GetColorsUseCase
    extends UseCase<PaginatedResult<CatalogColor>, ColorListQuery> {
  GetColorsUseCase(this._repository);
  final ColorsRepository _repository;

  @override
  Future<Either<Failure, PaginatedResult<CatalogColor>>> call(
    ColorListQuery params,
  ) => _repository.getColors(params);
}
