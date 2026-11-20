import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/features/catalog/data/models/brand_model.dart';
import 'package:accounting_software/app/features/catalog/domain/entity/brand_draft.dart';
import 'package:accounting_software/app/features/catalog/domain/entity/brand_list_query.dart';
import 'package:accounting_software/app/features/catalog/domain/entity/brand_logo_upload.dart';

abstract interface class BrandsRemoteDataSource {
  Future<ApiResult<PaginatedResult<BrandModel>>> getBrands(
    BrandListQuery query,
  );

  Future<ApiResult<BrandModel>> createBrand(BrandDraft draft);

  Future<ApiResult<BrandModel>> updateBrand({
    required int id,
    required BrandDraft draft,
  });

  Future<ApiResult<Unit>> setBrandActive({
    required int id,
    required bool isActive,
  });

  Future<ApiResult<Unit>> deleteBrand(int id);

  /// Uploads to Storage and returns the public URL.
  Future<ApiResult<String>> uploadLogo(BrandLogoUpload upload);
}
