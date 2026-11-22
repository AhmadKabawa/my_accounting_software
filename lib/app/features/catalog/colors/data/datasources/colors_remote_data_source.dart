import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/features/catalog/colors/data/models/color_model.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/entity/catalog_color_draft.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/entity/color_list_query.dart';

abstract interface class ColorsRemoteDataSource {
  Future<ApiResult<PaginatedResult<ColorModel>>> getColors(
    ColorListQuery query,
  );

  Future<ApiResult<ColorModel>> createColor(CatalogColorDraft draft);

  Future<ApiResult<ColorModel>> updateColor({
    required int id,
    required CatalogColorDraft draft,
  });

  Future<ApiResult<Unit>> deleteColor(int id);

  Future<ApiResult<Unit>> setColorActive({
    required int id,
    required bool isActive,
  });
}
