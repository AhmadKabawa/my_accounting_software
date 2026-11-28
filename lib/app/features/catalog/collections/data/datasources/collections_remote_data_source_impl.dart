import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:accounting_software/app/core/foundation/date/date_only.dart';
import 'package:accounting_software/app/core/foundation/image/image_upload.dart';
import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_parser.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/core/network/api_client_interface.dart';
import 'package:accounting_software/app/core/network/postgrest_helpers.dart';
import 'package:accounting_software/app/core/network/storage/storage_image_uploader.dart';
import 'package:accounting_software/app/core/network/storage/storage_target.dart';
import 'package:accounting_software/app/features/catalog/collections/data/collections_endpoint.dart';
import 'package:accounting_software/app/features/catalog/collections/data/datasources/collections_remote_data_source.dart';
import 'package:accounting_software/app/features/catalog/collections/data/models/collection_model.dart';
import 'package:accounting_software/app/features/catalog/collections/domain/entity/collection_draft.dart';
import 'package:accounting_software/app/features/catalog/collections/domain/entity/collection_list_query.dart';

class CollectionsRemoteDataSourceImpl implements CollectionsRemoteDataSource {
  const CollectionsRemoteDataSourceImpl(this._api, this._storage);
  final IApiClient _api;
  final StorageImageUploader _storage;

  @override
  Future<ApiResult<PaginatedResult<CollectionModel>>> getCollections(
    CollectionListQuery query,
  ) {
    final term = PostgrestValue.escapeFilter(query.search.trim());
    return _api.getPaginated<CollectionModel>(
      CollectionsEndpoint.collection,
      fromJson: CollectionModel.fromJson,
      page: query.page,
      limit: query.pageSize,
      parser: PaginatedParserPresets.supabase,
      queryParameters: {
        'select': CollectionsEndpoint.select,
        'order': _order(query),
        if (term.isNotEmpty)
          'or': '(name.ilike."*$term*",code.ilike."*$term*")',
        if (query.status == CollectionStatusFilter.active)
          'is_active': 'eq.true',
        if (query.status == CollectionStatusFilter.inactive)
          'is_active': 'eq.false',
      },
    );
  }

  @override
  Future<ApiResult<CollectionModel>> createCollection(CollectionDraft draft) =>
      _api.post<CollectionModel>(
        CollectionsEndpoint.collection,
        data: _json(draft),
        options: Options(headers: {'Prefer': 'return=representation'}),
        fromJsonList: _single,
      );

  @override
  Future<ApiResult<CollectionModel>> updateCollection({
    required int id,
    required CollectionDraft draft,
  }) => _api.patch<CollectionModel>(
    CollectionsEndpoint.collection,
    queryParameters: {'id': 'eq.$id'},
    data: _updateJson(draft),
    options: Options(headers: {'Prefer': 'return=representation'}),
    fromJsonList: _single,
  );

  @override
  Future<ApiResult<Unit>> deleteCollection(int id) => _api.delete(
    CollectionsEndpoint.collection,
    queryParameters: {'id': 'eq.$id'},
  );

  @override
  Future<ApiResult<Unit>> setCollectionActive({
    required int id,
    required bool isActive,
  }) => _api.patch<Unit>(
    CollectionsEndpoint.collection,
    queryParameters: {'id': 'eq.$id'},
    data: {'is_active': isActive},
    options: Options(headers: {'Prefer': 'return=minimal'}),
    fromJson: (_) => unit,
  );

  @override
  Future<ApiResult<String>> uploadImage(ImageUpload image) => _storage.upload(
    target: const StorageTarget(
      bucket: CollectionsEndpoint.imageBucket,
      folder: CollectionsEndpoint.imageFolder,
    ),
    image: image,
  );

  String _order(CollectionListQuery query) {
    final terms = [
      for (final sort in query.sorts)
        '${sort.field.column}.${sort.ascending ? 'asc' : 'desc'}',
    ];
    final hasName = query.sorts.any(
      (sort) => sort.field == CollectionSortField.name,
    );
    return [...terms, if (!hasName) 'name.asc', 'id.asc'].join(',');
  }

  CollectionModel _single(List<dynamic> rows) =>
      PostgrestValue.single(rows, CollectionModel.fromJson, what: 'collection');

  Map<String, dynamic> _updateJson(CollectionDraft draft) {
    final json = _json(draft);
    if (draft.isActive == null) json.remove('is_active');
    return json;
  }

  Map<String, dynamic> _json(CollectionDraft draft) => {
    'name': draft.name.trim(),
    'code': draft.code.trim(),
    'description': PostgrestValue.nullableTrim(draft.description),
    'image': PostgrestValue.nullableTrim(draft.image),
    'start_date': draft.startDate == null
        ? null
        : DateOnly.toApiString(draft.startDate!),
    'end_date': draft.endDate == null
        ? null
        : DateOnly.toApiString(draft.endDate!),
    'is_active': draft.isActive ?? true,
  };
}
