import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/entity/product_type_attribute_link.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/entity/product_type_link_option.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/entity/product_type_option_set_link.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/entity/product_type_size_group_link.dart';

abstract interface class ProductTypeLinksRepository {
  Future<Either<Failure, List<ProductTypeSizeGroupLink>>> getSizeGroupLinks(
    int id,
  );
  Future<Either<Failure, List<ProductTypeAttributeLink>>> getAttributeLinks(
    int id,
  );
  Future<Either<Failure, List<ProductTypeOptionSetLink>>> getOptionSetLinks(
    int id,
  );
  Future<Either<Failure, List<ProductTypeLinkOption>>> getSizeGroupOptions();
  Future<Either<Failure, List<ProductTypeLinkOption>>> getAttributeOptions();
  Future<Either<Failure, List<ProductTypeLinkOption>>> getOptionSetOptions();
  Future<Either<Failure, List<ProductTypeLinkOption>>> getGenderOptions();
  Future<Either<Failure, Unit>> createSizeGroupLink(Map<String, dynamic> body);
  Future<Either<Failure, Unit>> patchSizeGroupLink(
    int id,
    Map<String, dynamic> body,
  );
  Future<Either<Failure, Unit>> deleteSizeGroupLink(int id);
  Future<Either<Failure, Unit>> createAttributeLink(Map<String, dynamic> body);
  Future<Either<Failure, Unit>> patchAttributeLink(
    int productTypeId,
    int attributeId,
    Map<String, dynamic> body,
  );
  Future<Either<Failure, Unit>> deleteAttributeLink(
    int productTypeId,
    int attributeId,
  );
  Future<Either<Failure, Unit>> createOptionSetLink(Map<String, dynamic> body);
  Future<Either<Failure, Unit>> patchOptionSetLink(
    int productTypeId,
    int optionSetId,
    Map<String, dynamic> body,
  );
  Future<Either<Failure, Unit>> deleteOptionSetLink(
    int productTypeId,
    int optionSetId,
  );
  Future<Either<Failure, int>> getPublishedProductCount(int productTypeId);
}
