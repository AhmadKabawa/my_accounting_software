import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/presentation/state_management/base_cubit.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/flash_messages.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/message_view_widgets.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/entity/color_list_query.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/usecase/get_colors_use_case.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/usecase/set_color_active_use_case.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/cubit/colors_list/colors_list_effect.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/cubit/colors_list/colors_list_state.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/localization/colors_keys.dart';

class ColorsListCubit extends BaseCubit<ColorsListState, ColorsListEffect> {
  ColorsListCubit({
    required GetColorsUseCase getColors,
    required SetColorActiveUseCase setColorActive,
    required FlashMessages flashMessages,
  }) : _getColors = getColors,
       _setColorActive = setColorActive,
       _flashMessages = flashMessages,
       super(const ColorsListState());

  final GetColorsUseCase _getColors;
  final SetColorActiveUseCase _setColorActive;
  final FlashMessages _flashMessages;

  Timer? _searchTimer;
  int _requestVersion = 0;

  Future<void> load() async {
    _searchTimer?.cancel();
    final version = ++_requestVersion;
    final previous = state.result;
    emit(
      state.copyWith(
        status: previous == null
            ? ColorsListStatus.loading
            : ColorsListStatus.refreshing,
        clearFailure: true,
      ),
    );

    final response = await _getColors(state.query);
    if (isClosed || version != _requestVersion) return;

    response.fold(
      (failure) => emit(
        state.copyWith(
          status: ColorsListStatus.failed,
          result: previous,
          failure: failure,
        ),
      ),
      (page) => emit(
        state.copyWith(
          status: ColorsListStatus.ready,
          result: page,
          clearFailure: true,
        ),
      ),
    );
  }

  void searchChanged(String value) {
    final query = state.query.copyWith(search: value, page: 1);
    _requestVersion++;
    _searchTimer?.cancel();
    emit(state.copyWith(query: query, clearFailure: true));
    _searchTimer = Timer(const Duration(milliseconds: 300), () {
      if (!isClosed) load();
    });
  }

  Future<void> setStatus(ColorStatusFilter status) {
    if (state.query.status == status) return Future.value();
    _updateQuery(state.query.copyWith(status: status, page: 1));
    return load();
  }

  Future<void> setSort(ColorSortField field, {required bool ascending}) {
    final query = state.query;
    if (query.sortField == field && query.sortAscending == ascending) {
      return Future.value();
    }
    _updateQuery(
      query.copyWith(sortField: field, sortAscending: ascending, page: 1),
    );
    return load();
  }

  Future<void> setPage(int page) {
    if (page < 1 || page == state.query.page) return Future.value();
    _updateQuery(state.query.copyWith(page: page));
    return load();
  }

  Future<void> clearFilters() {
    _searchTimer?.cancel();
    _searchTimer = null;
    _updateQuery(
      state.query.copyWith(search: '', status: ColorStatusFilter.all, page: 1),
    );
    return load();
  }

  Future<void> refresh() => load();

  Future<void> activate(int id) async {
    final result = await _setColorActive(
      SetColorActiveParams(id: id, isActive: true),
    );
    if (isClosed) return;
    if (result.isLeft()) {
      final failure = result.fold<Failure?>((failure) => failure, (_) => null);
      if (failure != null) {
        _flashMessages.post(failure.messageKey, MessageType.error);
      }
      return;
    }
    _flashMessages.post(ColorsKeys.statusUpdated, MessageType.success);
    emitEffect(const ColorsMutatedEffect(ColorsMutationKind.statusChanged));
    await load();
  }

  Future<Either<Failure, Unit>> deactivate(int id) async {
    final result = await _setColorActive(
      SetColorActiveParams(id: id, isActive: false),
    );
    if (isClosed) return result;
    if (result.isRight()) {
      _flashMessages.post(ColorsKeys.statusUpdated, MessageType.success);
      emitEffect(const ColorsMutatedEffect(ColorsMutationKind.statusChanged));
      await load();
    }
    return result;
  }

  Future<void> onColorSaved({required bool isNew}) async {
    if (isClosed) return;
    emitEffect(
      ColorsMutatedEffect(
        isNew ? ColorsMutationKind.created : ColorsMutationKind.updated,
      ),
    );
    await load();
  }

  void _updateQuery(ColorListQuery query) {
    emit(state.copyWith(query: query, clearFailure: true));
  }

  @override
  Future<void> close() {
    _searchTimer?.cancel();
    _requestVersion++;
    return super.close();
  }
}
