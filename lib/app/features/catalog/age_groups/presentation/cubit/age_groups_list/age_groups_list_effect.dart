import 'package:accounting_software/app/core/presentation/state_management/paged_list/paged_list_cubit.dart';
sealed class AgeGroupsListEffect { const AgeGroupsListEffect(); }
class AgeGroupsMutatedEffect extends AgeGroupsListEffect {
  const AgeGroupsMutatedEffect(this.kind);
  factory AgeGroupsMutatedEffect.fromPaged(PagedMutationKind kind) => AgeGroupsMutatedEffect(kind);
  final PagedMutationKind kind;
}
