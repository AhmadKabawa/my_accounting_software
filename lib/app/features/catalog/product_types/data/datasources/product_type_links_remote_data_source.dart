import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/entity/product_type_attribute_link.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/entity/product_type_link_option.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/entity/product_type_option_set_link.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/entity/product_type_size_group_link.dart';

abstract interface class ProductTypeLinksRemoteDataSource {
  Future<ApiResult<List<ProductTypeSizeGroupLink>>> getSizeGroupLinks(int id);
  Future<ApiResult<List<ProductTypeAttributeLink>>> getAttributeLinks(int id);
  Future<ApiResult<List<ProductTypeOptionSetLink>>> getOptionSetLinks(int id);
  Future<ApiResult<List<ProductTypeLinkOption>>> getSizeGroupOptions();
  Future<ApiResult<List<ProductTypeLinkOption>>> getAttributeOptions();
  Future<ApiResult<List<ProductTypeLinkOption>>> getOptionSetOptions();
  Future<ApiResult<List<ProductTypeLinkOption>>> getGenderOptions();
  Future<ApiResult<Unit>> createSizeGroupLink(Map<String, dynamic> body);
  Future<ApiResult<Unit>> patchSizeGroupLink(int id, Map<String, dynamic> body);
  Future<ApiResult<Unit>> deleteSizeGroupLink(int id);
  Future<ApiResult<Unit>> createAttributeLink(Map<String, dynamic> body);
  Future<ApiResult<Unit>> patchAttributeLink(
    int productTypeId,
    int attributeId,
    Map<String, dynamic> body,
  );
  Future<ApiResult<Unit>> deleteAttributeLink(
    int productTypeId,
    int attributeId,
  );
  Future<ApiResult<Unit>> createOptionSetLink(Map<String, dynamic> body);
  Future<ApiResult<Unit>> patchOptionSetLink(
    int productTypeId,
    int optionSetId,
    Map<String, dynamic> body,
  );
  Future<ApiResult<Unit>> deleteOptionSetLink(
    int productTypeId,
    int optionSetId,
  );
  Future<ApiResult<int>> getPublishedProductCount(int productTypeId);
}
