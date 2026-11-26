import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/entity/product_type.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/entity/product_type_draft.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/entity/product_type_list_query.dart';

abstract interface class ProductTypesRepository {
  Future<Either<Failure, PaginatedResult<ProductType>>> getPage(
    ProductTypeListQuery query,
  );

  Future<Either<Failure, ProductType>> create(ProductTypeDraft draft);

  Future<Either<Failure, ProductType>> update({
    required int id,
    required ProductTypeDraft draft,
  });

  Future<Either<Failure, Unit>> setActive({
    required int id,
    required bool isActive,
  });

  Future<Either<Failure, Unit>> delete(int id);
}
