import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/core/access/domain/get_my_access_usecase.dart';
import 'package:accounting_software/app/core/access/models/access_snapshot.dart';
import 'package:accounting_software/app/core/access/permission.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/base/use_case.dart';

part 'access_state.dart';

/// Holds the server-authoritative access snapshot. No role or permission is
/// granted until get_my_access() succeeds; every failure is fail-closed.
class AccessCubit extends Cubit<AccessState> {
  AccessCubit({required GetMyAccessUseCase getMyAccess})
    : _getMyAccess = getMyAccess,
      super(const AccessState());

  final GetMyAccessUseCase _getMyAccess;
  int _requestSequence = 0;

  Future<void> load({int? preferredBranchId}) async {
    final request = ++_requestSequence;
    final branchToKeep = preferredBranchId ?? state.selectedBranchId;
    emit(
      AccessState(status: AccessStatus.loading, selectedBranchId: branchToKeep),
    );

    final result = await _getMyAccess(NoParams());
    if (isClosed || request != _requestSequence) return;

    result.fold(
      (failure) => emit(
        AccessState(
          status: AccessStatus.failure,
          failure: failure,
          selectedBranchId: branchToKeep,
        ),
      ),
      (snapshot) {
        final viewableBranches = snapshot.viewableBranches;
        int? selected;
        if (viewableBranches.any((branch) => branch.id == branchToKeep)) {
          selected = branchToKeep;
        } else if (viewableBranches.length == 1) {
          selected = viewableBranches.single.id;
        }
        emit(
          AccessState(
            status: AccessStatus.ready,
            snapshot: snapshot,
            selectedBranchId: selected,
          ),
        );
      },
    );
  }

  Future<void> retry() => load(preferredBranchId: state.selectedBranchId);

  /// A branch change is accepted only for a branch in the current snapshot.
  /// The access snapshot is refreshed before the new scope is considered ready.
  Future<void> selectBranch(int branchId) async {
    final snapshot = state.snapshot;
    if (!state.isReady ||
        snapshot == null ||
        !snapshot.viewableBranches.any((item) => item.id == branchId)) {
      return;
    }
    await load(preferredBranchId: branchId);
  }

  void clear() {
    _requestSequence++;
    emit(const AccessState());
  }

  bool can(Permission permission) {
    final snapshot = state.snapshot;
    if (!state.isReady || snapshot == null) return false;
    return snapshot.permissions.any((granted) => granted.covers(permission));
  }

  bool canOperate(Permission permission) =>
      can(permission) && canOperateInSelectedBranch;

  bool canAny(Iterable<Permission> permissions) => permissions.any(can);

  bool canAll(Iterable<Permission> permissions) =>
      state.isReady && permissions.every(can);

  bool get canOperateInSelectedBranch {
    final snapshot = state.snapshot;
    if (!state.isReady || snapshot == null || state.selectedBranchId == null) {
      return false;
    }
    return snapshot.branches.any(
      (branch) =>
          branch.id == state.selectedBranchId &&
          branch.canView &&
          branch.canOperate,
    );
  }

  Either<Failure, Unit> require(Permission permission) =>
      can(permission) ? const Right(unit) : Left(PermissionFailure());
}
