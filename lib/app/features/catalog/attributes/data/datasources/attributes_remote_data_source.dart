import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/features/catalog/attributes/data/models/attribute_model.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/entity/attribute_lookup_choices.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/entity/attribute_draft.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/entity/attribute_list_query.dart';

abstract interface class AttributesRemoteDataSource {
  Future<ApiResult<PaginatedResult<AttributeModel>>> getAttributes(
    AttributeListQuery query,
  );
  Future<ApiResult<AttributeModel>> createAttribute(AttributeDraft draft);
  Future<ApiResult<Unit>> deleteAttribute(int id);
  Future<ApiResult<AttributeModel>> updateAttribute({
    required int id,
    required AttributeDraft draft,
  });
  Future<ApiResult<Unit>> setAttributeActive({
    required int id,
    required bool isActive,
  });
  Future<ApiResult<List<AttributeUnitChoice>>> getUnitChoices();
  Future<ApiResult<List<AttributeOptionSetChoice>>> getOptionSetChoices();
}
