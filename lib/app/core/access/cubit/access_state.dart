part of 'access_cubit.dart';

enum AccessStatus { initial, loading, ready, failure }

class AccessState extends Equatable {
  const AccessState({
    this.status = AccessStatus.initial,
    this.snapshot,
    this.failure,
    this.selectedBranchId,
  });

  final AccessStatus status;
  final AccessSnapshot? snapshot;
  final Failure? failure;
  final int? selectedBranchId;

  bool get isReady => status == AccessStatus.ready && snapshot != null;

  /// Access loaded successfully, but the account cannot view any branch.
  bool get hasNoAvailableBranches =>
      isReady && snapshot!.viewableBranches.isEmpty;

  /// Ready, no branch chosen yet, and more than one branch to choose from
  /// (a single viewable branch is selected automatically, decision 67).
  bool get needsBranchSelection {
    if (!isReady || selectedBranchId != null) return false;
    return snapshot!.viewableBranches.length > 1;
  }

  @override
  List<Object?> get props => [status, snapshot, failure, selectedBranchId];
}
