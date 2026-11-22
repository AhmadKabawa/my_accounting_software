import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/entity/color_stats.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/entity/catalog_color.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/entity/catalog_color_draft.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/entity/color_list_query.dart';

abstract interface class ColorsRepository {
  Future<Either<Failure, ColorStats>> getColorStats();

  Future<Either<Failure, Unit>> deleteColor(int id);

  Future<Either<Failure, PaginatedResult<CatalogColor>>> getColors(
    ColorListQuery query,
  );

  Future<Either<Failure, CatalogColor>> createColor(CatalogColorDraft draft);

  Future<Either<Failure, CatalogColor>> updateColor({
    required int id,
    required CatalogColorDraft draft,
  });

  Future<Either<Failure, Unit>> setColorActive({
    required int id,
    required bool isActive,
  });
}
