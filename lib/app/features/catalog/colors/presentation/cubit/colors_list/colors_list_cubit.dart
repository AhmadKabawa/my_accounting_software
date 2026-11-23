import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/config/app_config.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/state_management/paged_list/paged_list_cubit.dart';
import 'package:accounting_software/app/core/presentation/state_management/paged_list/paged_result.dart';
import 'package:accounting_software/app/core/foundation/types/bulk_result.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/entity/catalog_color.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/entity/color_list_query.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/usecase/get_colors_use_case.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/usecase/delete_color_use_case.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/usecase/set_color_active_use_case.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/cubit/colors_list/colors_list_effect.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/localization/colors_keys.dart';

class ColorsListCubit
    extends PagedListCubit<CatalogColor, ColorListQuery, ColorsListEffect> {
  ColorsListCubit({
    required GetColorsUseCase getColors,
    required SetColorActiveUseCase setColorActive,
    required DeleteColorUseCase deleteColor,
    required super.flashMessages,
  }) : _getColors = getColors,
       _setColorActive = setColorActive,
       _deleteColor = deleteColor,
       super(
         initialQuery: const ColorListQuery(
           page: AppConfig.defaultPage,
           pageSize: AppConfig.defaultPageSize,
         ),
       );

  final GetColorsUseCase _getColors;
  final SetColorActiveUseCase _setColorActive;
  final DeleteColorUseCase _deleteColor;

  @override
  Future<Either<Failure, PagedResult<CatalogColor>>> fetch(
    ColorListQuery query,
  ) => _getColors(query);

  @override
  Future<Either<Failure, Unit>> deleteItem(CatalogColor item) =>
      _deleteColor(DeleteColorParams(item.id));

  @override
  AppKey get deletedMessageKey => ColorsKeys.deleted;

  @override
  ColorsListEffect buildMutationEffect(PagedMutationKind kind) =>
      ColorsMutatedEffect(switch (kind) {
        PagedMutationKind.created => ColorsMutationKind.created,
        PagedMutationKind.updated => ColorsMutationKind.updated,
        PagedMutationKind.statusChanged => ColorsMutationKind.statusChanged,
        PagedMutationKind.deleted => ColorsMutationKind.deleted,
      });

  Future<void> setStatus(ColorStatusFilter status) async {
    if (state.query.status == status) return;
    await applyQueryAndLoad(state.query.withStatus(status));
  }

  Future<void> setSorts(List<ColorSort> sorts) async {
    final query = state.query.withSorts(sorts);
    if (query == state.query) return;
    await applyQueryAndLoad(query);
  }

  Future<Either<Failure, Unit>> activate(int id) => runMutation(
    () => _setColorActive(SetColorActiveParams(id: id, isActive: true)),
    kind: PagedMutationKind.statusChanged,
    successMessage: ColorsKeys.statusUpdated,
    flashFailure: true,
    rowId: id,
  );

  Future<Either<Failure, Unit>> deactivate(int id) => runMutation(
    () => _setColorActive(SetColorActiveParams(id: id, isActive: false)),
    kind: PagedMutationKind.statusChanged,
    successMessage: ColorsKeys.statusUpdated,
    flashFailure: true,
    rowId: id,
  );

  Future<BulkResult<CatalogColor>> bulkActivate(
    Iterable<CatalogColor> colors,
  ) => runBulk(
    items: colors,
    action: (color) =>
        _setColorActive(SetColorActiveParams(id: color.id, isActive: true)),
    kind: PagedMutationKind.statusChanged,
    successMessage: ColorsKeys.statusUpdated,
  );

  Future<BulkResult<CatalogColor>> bulkDeactivate(
    Iterable<CatalogColor> colors,
  ) => runBulk(
    items: colors,
    action: (color) =>
        _setColorActive(SetColorActiveParams(id: color.id, isActive: false)),
    kind: PagedMutationKind.statusChanged,
    successMessage: ColorsKeys.statusUpdated,
  );

  Future<BulkResult<CatalogColor>> bulkDelete(Iterable<CatalogColor> colors) =>
      runBulk(
        items: colors,
        action: (color) => _deleteColor(DeleteColorParams(color.id)),
        kind: PagedMutationKind.deleted,
        successMessage: ColorsKeys.deleted,
      );

  Future<void> onColorSaved({required bool isNew}) => reloadAfterMutation(
    isNew ? PagedMutationKind.created : PagedMutationKind.updated,
  );
}
