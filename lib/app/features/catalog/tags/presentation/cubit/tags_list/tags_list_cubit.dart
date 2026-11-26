import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/config/app_config.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/state_management/paged_list/paged_list_cubit.dart';
import 'package:accounting_software/app/core/presentation/state_management/paged_list/paged_result.dart';
import 'package:accounting_software/app/core/foundation/types/bulk_result.dart';
import 'package:accounting_software/app/features/catalog/tags/domain/entity/catalog_tag.dart';
import 'package:accounting_software/app/features/catalog/tags/domain/entity/tag_list_query.dart';
import 'package:accounting_software/app/features/catalog/tags/domain/usecase/get_tags_use_case.dart';
import 'package:accounting_software/app/features/catalog/tags/domain/usecase/delete_tag_use_case.dart';
import 'package:accounting_software/app/features/catalog/tags/domain/usecase/set_tag_active_use_case.dart';
import 'package:accounting_software/app/features/catalog/tags/presentation/cubit/tags_list/tags_list_effect.dart';
import 'package:accounting_software/app/features/catalog/tags/presentation/localization/tags_keys.dart';

class TagsListCubit
    extends PagedListCubit<CatalogTag, TagListQuery, TagsListEffect> {
  TagsListCubit({
    required GetTagsUseCase getTags,
    required SetTagActiveUseCase setTagActive,
    required DeleteTagUseCase deleteTag,
    required super.flashMessages,
  }) : _getTags = getTags,
       _setTagActive = setTagActive,
       _deleteTag = deleteTag,
       super(
         initialQuery: const TagListQuery(
           page: AppConfig.defaultPage,
           pageSize: AppConfig.defaultPageSize,
         ),
       );

  final GetTagsUseCase _getTags;
  final SetTagActiveUseCase _setTagActive;
  final DeleteTagUseCase _deleteTag;

  @override
  Future<Either<Failure, PagedResult<CatalogTag>>> fetch(
    TagListQuery query,
  ) => _getTags(query);

  @override
  Future<Either<Failure, Unit>> deleteItem(CatalogTag item) =>
      _deleteTag(DeleteTagParams(item.id));

  @override
  AppKey get deletedMessageKey => TagsKeys.deleted;

  @override
  TagsListEffect buildMutationEffect(PagedMutationKind kind) =>
      TagsMutatedEffect(switch (kind) {
        PagedMutationKind.created => TagsMutationKind.created,
        PagedMutationKind.updated => TagsMutationKind.updated,
        PagedMutationKind.statusChanged => TagsMutationKind.statusChanged,
        PagedMutationKind.deleted => TagsMutationKind.deleted,
      });

  Future<void> setStatus(TagStatusFilter status) async {
    if (state.query.status == status) return;
    await applyQueryAndLoad(state.query.withStatus(status));
  }

  Future<void> setSorts(List<TagSort> sorts) async {
    final query = state.query.withSorts(sorts);
    if (query == state.query) return;
    await applyQueryAndLoad(query);
  }

  Future<Either<Failure, Unit>> activate(int id) => runMutation(
    () => _setTagActive(SetTagActiveParams(id: id, isActive: true)),
    kind: PagedMutationKind.statusChanged,
    successMessage: TagsKeys.statusUpdated,
    flashFailure: true,
    rowId: id,
  );

  Future<Either<Failure, Unit>> deactivate(int id) => runMutation(
    () => _setTagActive(SetTagActiveParams(id: id, isActive: false)),
    kind: PagedMutationKind.statusChanged,
    successMessage: TagsKeys.statusUpdated,
    flashFailure: true,
    rowId: id,
  );

  Future<BulkResult<CatalogTag>> bulkActivate(
    Iterable<CatalogTag> tags,
  ) => runBulk(
    items: tags,
    action: (tag) =>
        _setTagActive(SetTagActiveParams(id: tag.id, isActive: true)),
    kind: PagedMutationKind.statusChanged,
    successMessage: TagsKeys.statusUpdated,
  );

  Future<BulkResult<CatalogTag>> bulkDeactivate(
    Iterable<CatalogTag> tags,
  ) => runBulk(
    items: tags,
    action: (tag) =>
        _setTagActive(SetTagActiveParams(id: tag.id, isActive: false)),
    kind: PagedMutationKind.statusChanged,
    successMessage: TagsKeys.statusUpdated,
  );

  Future<BulkResult<CatalogTag>> bulkDelete(Iterable<CatalogTag> tags) =>
      runBulk(
        items: tags,
        action: (tag) => _deleteTag(DeleteTagParams(tag.id)),
        kind: PagedMutationKind.deleted,
        successMessage: TagsKeys.deleted,
      );

  Future<void> onTagSaved({required bool isNew}) => reloadAfterMutation(
    isNew ? PagedMutationKind.created : PagedMutationKind.updated,
  );
}
