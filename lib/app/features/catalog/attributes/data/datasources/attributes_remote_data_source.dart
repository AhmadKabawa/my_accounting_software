import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/features/catalog/attributes/data/models/attribute_model.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/entity/attribute_draft.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/entity/attribute_list_query.dart';

class AttributeUnitChoice {
  const AttributeUnitChoice({
    required this.id,
    required this.name,
    required this.symbol,
    required this.isActive,
  });
  final int id;
  final String name;
  final String symbol;
  final bool isActive;
}

class AttributeOptionSetChoice {
  const AttributeOptionSetChoice({
    required this.id,
    required this.name,
    required this.code,
    required this.isActive,
  });
  final int id;
  final String name;
  final String code;
  final bool isActive;
}

abstract interface class AttributesRemoteDataSource {
  Future<ApiResult<PaginatedResult<AttributeModel>>> getAttributes(
    AttributeListQuery query,
  );
  Future<ApiResult<AttributeModel>> createAttribute(AttributeDraft draft);
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
