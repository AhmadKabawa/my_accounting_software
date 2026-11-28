import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_parser.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/core/network/api_client_interface.dart';
import 'package:accounting_software/app/core/network/postgrest_helpers.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/data/care_instructions_endpoint.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/data/datasources/care_instructions_remote_data_source.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/data/models/care_instruction_model.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/domain/entity/care_instruction_draft.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/domain/entity/care_instruction_list_query.dart';

class CareInstructionsRemoteDataSourceImpl
    implements CareInstructionsRemoteDataSource {
  const CareInstructionsRemoteDataSourceImpl(this._api);
  final IApiClient _api;

  @override
  Future<ApiResult<PaginatedResult<CareInstructionModel>>> getCareInstructions(
    CareInstructionListQuery q,
  ) {
    final term = PostgrestValue.escapeFilter(q.search.trim());
    return _api.getPaginated<CareInstructionModel>(
      CareInstructionsEndpoint.collection,
      fromJson: CareInstructionModel.fromJson,
      page: q.page,
      limit: q.pageSize,
      parser: PaginatedParserPresets.supabase,
      queryParameters: {
        'select': CareInstructionsEndpoint.select,
        'order': 'sort_order.asc,name.asc,id.asc',
        if (term.isNotEmpty)
          'or': '(name.ilike."*$term*",code.ilike."*$term*")',
        if (q.status == CareInstructionStatusFilter.active)
          'is_active': 'eq.true',
        if (q.status == CareInstructionStatusFilter.inactive)
          'is_active': 'eq.false',
        if (q.careType != null) 'care_type': 'eq.${q.careType!.apiValue}',
      },
    );
  }

  @override
  Future<ApiResult<CareInstructionModel>> createCareInstruction(
    CareInstructionDraft d,
  ) => _api.post<CareInstructionModel>(
    CareInstructionsEndpoint.collection,
    data: CareInstructionModel.toWriteJson(d),
    options: Options(headers: {'Prefer': 'return=representation'}),
    fromJsonList: _single,
  );

  @override
  Future<ApiResult<CareInstructionModel>> updateCareInstruction({
    required int id,
    required CareInstructionDraft draft,
  }) {
    final json = CareInstructionModel.toWriteJson(draft);
    if (draft.isActive == null) json.remove('is_active');
    return _api.patch<CareInstructionModel>(
      CareInstructionsEndpoint.collection,
      queryParameters: {'id': 'eq.$id'},
      data: json,
      options: Options(headers: {'Prefer': 'return=representation'}),
      fromJsonList: _single,
    );
  }

  @override
  Future<ApiResult<Unit>> deleteCareInstruction(int id) => _api.delete(
    CareInstructionsEndpoint.collection,
    queryParameters: {'id': 'eq.$id'},
  );

  @override
  Future<ApiResult<Unit>> setCareInstructionActive({
    required int id,
    required bool isActive,
  }) => _api.patch<Unit>(
    CareInstructionsEndpoint.collection,
    queryParameters: {'id': 'eq.$id'},
    data: {'is_active': isActive},
    options: Options(headers: {'Prefer': 'return=minimal'}),
    fromJson: (_) => unit,
  );

  CareInstructionModel _single(List<dynamic> rows) => PostgrestValue.single(
    rows,
    CareInstructionModel.fromJson,
    what: 'care instruction',
  );
}
