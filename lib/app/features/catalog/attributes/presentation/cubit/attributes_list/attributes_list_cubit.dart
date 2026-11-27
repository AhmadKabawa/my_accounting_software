import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/config/app_config.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/state_management/paged_list/paged_list_cubit.dart';
import 'package:accounting_software/app/core/presentation/state_management/paged_list/paged_result.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/flash_messages.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/entity/attribute_list_query.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/entity/catalog_attribute.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/usecase/get_attributes_use_case.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/usecase/delete_attribute_use_case.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/usecase/set_attribute_active_use_case.dart';
import 'package:accounting_software/app/features/catalog/attributes/presentation/cubit/attributes_list/attributes_list_effect.dart';
import 'package:accounting_software/app/features/catalog/attributes/presentation/localization/attributes_keys.dart';

class AttributesListCubit
    extends
        PagedListCubit<
          CatalogAttribute,
          AttributeListQuery,
          AttributesListEffect
        > {
  AttributesListCubit({
    required GetAttributesUseCase getAttributes,
    required SetAttributeActiveUseCase setActive,
    required DeleteAttributeUseCase deleteAttribute,
    required FlashMessages flashMessages,
  }) : _getAttributes = getAttributes,
       _setActive = setActive,
       _deleteAttribute = deleteAttribute,
       super(
         initialQuery: const AttributeListQuery(
           page: AppConfig.defaultPage,
           pageSize: AppConfig.defaultPageSize,
         ),
         flashMessages: flashMessages,
       );

  final GetAttributesUseCase _getAttributes;
  final SetAttributeActiveUseCase _setActive;
  final DeleteAttributeUseCase _deleteAttribute;

  @override
  Future<Either<Failure, PagedResult<CatalogAttribute>>> fetch(
    AttributeListQuery query,
  ) => _getAttributes(query);

  @override
  Future<Either<Failure, Unit>> deleteItem(CatalogAttribute item) => _deleteAttribute(item.id);

  @override
  Failure? beforeDelete(CatalogAttribute item) => item.canDelete
      ? null
      : const ValidationFailure(messageKey: AttributesKeys.deleteBlocked);

  @override
  AppKey get deletedMessageKey => AttributesKeys.deleted;

  @override
  AttributesListEffect buildMutationEffect(PagedMutationKind kind) =>
      AttributesMutatedEffect.fromPaged(kind);

  Future<void> setStatus(AttributeStatusFilter status) =>
      _apply(state.query.copyWith(status: status, page: 1));

  Future<void> setDataType(AttributeDataType? type) => _apply(
    state.query.copyWith(dataType: type, clearDataType: type == null, page: 1),
  );

  Future<void> setFilterable(AttributeFilterableFilter filterable) =>
      _apply(state.query.copyWith(filterable: filterable, page: 1));

  Future<void> _apply(AttributeListQuery query) async {
    if (state.query != query) await applyQueryAndLoad(query);
  }

  Future<Either<Failure, Unit>> activate(int id) => runMutation(
    () => _setActive(SetAttributeActiveParams(id: id, isActive: true)),
    kind: PagedMutationKind.statusChanged,
    successMessage: AttributesKeys.statusUpdated,
    flashFailure: true,
    rowId: id,
  );

  Future<Either<Failure, Unit>> deactivate(int id) => runMutation(
    () => _setActive(SetAttributeActiveParams(id: id, isActive: false)),
    kind: PagedMutationKind.statusChanged,
    successMessage: AttributesKeys.statusUpdated,
    flashFailure: true,
    rowId: id,
  );

  Future<void> onSaved({required bool isNew}) => reloadAfterMutation(
    isNew ? PagedMutationKind.created : PagedMutationKind.updated,
  );
}
