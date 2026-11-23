import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/types/paged_query.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/localization/keys/catalog_ui_keys.dart';
import 'package:accounting_software/app/core/presentation/state_management/base_cubit.dart';
import 'package:accounting_software/app/core/presentation/state_management/paged_list/paged_list_state.dart';
import 'package:accounting_software/app/core/presentation/state_management/paged_list/bulk_result.dart';
import 'package:accounting_software/app/core/presentation/state_management/list_selection_cubit.dart';
import 'package:accounting_software/app/core/presentation/state_management/paged_list/paged_result.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/flash_messages.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/message_view_widgets.dart';

enum PagedMutationKind { created, updated, statusChanged, deleted }

const searchDebounceDuration = Duration(milliseconds: 300);

abstract class PagedListCubit<T, Q extends PagedQuery<Q>, E>
    extends BaseCubit<PagedListState<T, Q>, E> {
  PagedListCubit({
    required Q initialQuery,
    required FlashMessages flashMessages,
  }) : _flashMessages = flashMessages,
       super(PagedListState<T, Q>(query: initialQuery));

  final FlashMessages _flashMessages;
  final ListSelectionCubit<Object> selection = ListSelectionCubit<Object>();
  Timer? _searchTimer;
  int _requestVersion = 0;

  Future<Either<Failure, PagedResult<T>>> fetch(Q query);
  Future<Either<Failure, Unit>> deleteItem(T item);
  AppKey get deletedMessageKey;
  E buildMutationEffect(PagedMutationKind kind);

  /// Return a failure to reject deletion before [deleteItem] is called.
  Failure? beforeDelete(T item) => null;

  Future<void> load() async {
    selection.clear();
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
    selection.clear();
    _requestVersion++;
    _searchTimer?.cancel();
    emit(state.copyWith(query: state.query.withSearch(value), clearFailure: true));
    _searchTimer = Timer(searchDebounceDuration, () {
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
    selection.clear();
    emit(state.copyWith(query: query, clearFailure: true));
  }

  @protected
  Future<void> applyQueryAndLoad(Q query) async {
    applyQuery(query);
    await load();
  }

  @protected
  void publishMutation(PagedMutationKind kind) {
    emitEffect(buildMutationEffect(kind));
  }

  @protected
  Future<void> reloadAfterMutation(PagedMutationKind kind) async {
    if (isClosed) return;
    publishMutation(kind);
    await load();
  }

  @protected
  Future<Either<Failure, Unit>> runMutation(
    Future<Either<Failure, Unit>> Function() action, {
    required PagedMutationKind kind,
    required AppKey successMessage,
    bool flashFailure = false,
  }) async {
    final response = await action();
    if (isClosed) return response;
    if (response.isRight()) {
      _flashMessages.post(successMessage, MessageType.success);
      publishMutation(kind);
      await load();
    } else if (flashFailure) {
      response.fold(
        (failure) => _flashMessages.post(failure.messageKey, MessageType.error),
        (_) {},
      );
    }
    return response;
  }

  @protected
  Future<BulkResult<T>> runBulk({
    required Iterable<T> items,
    required Future<Either<Failure, Unit>> Function(T item) action,
    required PagedMutationKind kind,
    required AppKey successMessage,
  }) async {
    final failures = <BulkFailure<T>>[];
    var succeeded = 0;
    for (final item in items) {
      if (isClosed) break;
      final result = await action(item);
      if (isClosed) break;
      result.fold(
        (failure) => failures.add(BulkFailure(item: item, reason: failure)),
        (_) => succeeded++,
      );
    }
    final result = BulkResult<T>(successCount: succeeded, failures: failures);
    if (!isClosed && (succeeded > 0 || failures.isNotEmpty)) {
      await load();
      if (!isClosed) {
        publishMutation(kind);
        final message = failures.isEmpty
            ? successMessage
            : failures.length == succeeded + failures.length
            ? CatalogUiKeys.bulkFailed
            : CatalogUiKeys.bulkPartiallyFailed;
        _flashMessages.post(
          message,
          failures.isEmpty ? MessageType.success : MessageType.error,
        );
      }
    }
    return result;
  }

  @override
  Future<void> close() {
    _searchTimer?.cancel();
    _searchTimer = null;
    _requestVersion++;
    selection.close();
    return super.close();
  }
}
