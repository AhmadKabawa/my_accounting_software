import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/types/paged_query.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/state_management/base_cubit.dart';
import 'package:accounting_software/app/core/presentation/state_management/paged_list/paged_list_state.dart';
import 'package:accounting_software/app/core/presentation/state_management/paged_list/paged_result.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/flash_messages.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/message_view_widgets.dart';

enum PagedMutationKind { created, updated, statusChanged, deleted }

abstract class PagedListCubit<T, Q extends PagedQuery<Q>, E>
    extends BaseCubit<PagedListState<T, Q>, E> {
  PagedListCubit({
    required Q initialQuery,
    required FlashMessages flashMessages,
  }) : _flashMessages = flashMessages,
       super(PagedListState<T, Q>(query: initialQuery));

  final FlashMessages _flashMessages;
  Timer? _searchTimer;
  int _requestVersion = 0;

  Future<Either<Failure, PagedResult<T>>> fetch(Q query);
  Future<Either<Failure, Unit>> deleteItem(T item);
  AppKey get deletedMessageKey;
  E buildMutationEffect(PagedMutationKind kind);

  /// Return a failure to reject deletion before [deleteItem] is called.
  Failure? beforeDelete(T item) => null;

  Future<void> load() async {
    _searchTimer?.cancel();
    _searchTimer = null;
    final version = ++_requestVersion;
    final query = state.query;
    final previous = state.result;
    emit(state.copyWith(
      status: previous == null
          ? PagedListStatus.loading
          : PagedListStatus.refreshing,
      clearFailure: true,
    ));

    final response = await fetch(query);
    if (isClosed || version != _requestVersion) return;

    response.fold(
      (failure) => emit(state.copyWith(
        status: PagedListStatus.failed,
        result: previous,
        failure: failure,
      )),
      (page) => emit(state.copyWith(
        status: PagedListStatus.ready,
        result: page,
        clearFailure: true,
      )),
    );
  }

  void searchChanged(String value) {
    _requestVersion++;
    _searchTimer?.cancel();
    emit(state.copyWith(query: state.query.withSearch(value), clearFailure: true));
    _searchTimer = Timer(const Duration(milliseconds: 300), () {
      _searchTimer = null;
      if (!isClosed) load();
    });
  }

  Future<void> setPage(int page) {
    if (page < 1 || page == state.query.page) return Future.value();
    applyQuery(state.query.withPage(page));
    return load();
  }

  Future<void> clearFilters() {
    _searchTimer?.cancel();
    _searchTimer = null;
    applyQuery(state.query.cleared());
    return load();
  }

  Future<void> refresh() => load();

  Future<Either<Failure, Unit>> delete(T item) async {
    final rejection = beforeDelete(item);
    if (rejection != null) return Left(rejection);

    final response = await deleteItem(item);
    if (isClosed || response.isLeft()) return response;

    final wasLastRowOnLaterPage =
        (state.result?.items.length ?? 0) <= 1 && state.query.page > 1;
    if (wasLastRowOnLaterPage) {
      applyQuery(state.query.withPage(state.query.page - 1));
    }
    await load();
    if (isClosed) return response;

    if (!wasLastRowOnLaterPage &&
        state.result != null &&
        state.result!.items.isEmpty &&
        state.query.page > 1) {
      applyQuery(state.query.withPage(state.query.page - 1));
      await load();
    }
    if (isClosed) return response;

    _flashMessages.post(deletedMessageKey, MessageType.success);
    emitEffect(buildMutationEffect(PagedMutationKind.deleted));
    return response;
  }

  /// Updates the query and clears any previously displayed failure.
  @protected
  void applyQuery(Q query) {
    emit(state.copyWith(query: query, clearFailure: true));
  }

  @protected
  void publishMutation(PagedMutationKind kind) {
    emitEffect(buildMutationEffect(kind));
  }

  @override
  Future<void> close() {
    _searchTimer?.cancel();
    _searchTimer = null;
    _requestVersion++;
    return super.close();
  }
}
