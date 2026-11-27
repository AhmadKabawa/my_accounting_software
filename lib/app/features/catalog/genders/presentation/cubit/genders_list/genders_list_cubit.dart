import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/config/app_config.dart';
import 'package:accounting_software/app/core/foundation/types/bulk_result.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/state_management/paged_list/paged_list_cubit.dart';
import 'package:accounting_software/app/core/presentation/state_management/paged_list/paged_result.dart';
import 'package:accounting_software/app/features/catalog/genders/domain/entity/gender.dart';
import 'package:accounting_software/app/features/catalog/genders/domain/entity/gender_list_query.dart';
import 'package:accounting_software/app/features/catalog/genders/domain/failures/gender_failures.dart';
import 'package:accounting_software/app/features/catalog/genders/domain/usecase/delete_gender_use_case.dart';
import 'package:accounting_software/app/features/catalog/genders/domain/usecase/get_genders_use_case.dart';
import 'package:accounting_software/app/features/catalog/genders/domain/usecase/set_gender_active_use_case.dart';
import 'package:accounting_software/app/features/catalog/genders/presentation/cubit/genders_list/genders_list_effect.dart';
import 'package:accounting_software/app/features/catalog/genders/presentation/localization/genders_keys.dart';

class GendersListCubit extends PagedListCubit<Gender, GenderListQuery, GendersListEffect> {
  GendersListCubit({
    required GetGendersUseCase get,
    required SetGenderActiveUseCase setActive,
    required DeleteGenderUseCase delete,
    required super.flashMessages,
  }) : _get = get,
       _setActive = setActive,
       _delete = delete,
       super(initialQuery: const GenderListQuery(
         page: AppConfig.defaultPage,
         pageSize: AppConfig.defaultPageSize,
       ));

  final GetGendersUseCase _get;
  final SetGenderActiveUseCase _setActive;
  final DeleteGenderUseCase _delete;

  @override
  Future<Either<Failure, PagedResult<Gender>>> fetch(GenderListQuery query) => _get(query);

  @override
  Future<Either<Failure, Unit>> deleteItem(Gender item) => _delete(DeleteGenderParams(item.id));

  @override
  Failure? beforeDelete(Gender item) {
    if (item.sizeGroupCount == null) return const GenderUsageUnknownFailure();
    if (item.sizeGroupCount! > 0) return const GenderInUseFailure();
    return null;
  }

  @override
  AppKey get deletedMessageKey => GendersKeys.deleted;

  @override
  GendersListEffect buildMutationEffect(PagedMutationKind kind) =>
      GendersMutatedEffect.fromPaged(kind);

  Future<void> setStatus(GenderStatusFilter value) async {
    if (state.query.status != value) await applyQueryAndLoad(state.query.withStatus(value));
  }

  Future<void> setSorts(List<GenderSort> values) async {
    final query = state.query.withSorts(values);
    if (query != state.query) await applyQueryAndLoad(query);
  }

  Future<Either<Failure, Unit>> activate(int id) => runMutation(
    () => _setActive(SetGenderActiveParams(id: id, isActive: true)),
    kind: PagedMutationKind.statusChanged,
    successMessage: GendersKeys.statusUpdated,
    flashFailure: true,
    rowId: id,
  );

  Future<Either<Failure, Unit>> deactivate(int id) => runMutation(
    () => _setActive(SetGenderActiveParams(id: id, isActive: false)),
    kind: PagedMutationKind.statusChanged,
    successMessage: GendersKeys.statusUpdated,
    flashFailure: true,
    rowId: id,
  );

  Future<BulkResult<Gender>> bulkActivate(Iterable<Gender> items) => runBulk(
    items: items,
    action: (item) => _setActive(SetGenderActiveParams(id: item.id, isActive: true)),
    kind: PagedMutationKind.statusChanged,
    successMessage: GendersKeys.statusUpdated,
  );

  Future<BulkResult<Gender>> bulkDeactivate(Iterable<Gender> items) => runBulk(
    items: items,
    action: (item) => _setActive(SetGenderActiveParams(id: item.id, isActive: false)),
    kind: PagedMutationKind.statusChanged,
    successMessage: GendersKeys.statusUpdated,
  );

  Future<BulkResult<Gender>> bulkDelete(Iterable<Gender> items) => runBulk(
    items: items,
    action: (item) {
      final failure = beforeDelete(item);
      return failure == null
          ? _delete(DeleteGenderParams(item.id))
          : Future.value(Left<Failure, Unit>(failure));
    },
    kind: PagedMutationKind.deleted,
    successMessage: GendersKeys.deleted,
  );

  Future<void> onGenderSaved({required bool isNew}) =>
      reloadAfterMutation(isNew ? PagedMutationKind.created : PagedMutationKind.updated);
}
