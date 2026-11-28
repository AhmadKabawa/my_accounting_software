import 'package:accounting_software/app/core/presentation/state_management/paged_list/paged_list_cubit.dart';

sealed class SizeGroupsListEffect {
  const SizeGroupsListEffect();
}

class SizeGroupsMutatedEffect extends SizeGroupsListEffect {
  const SizeGroupsMutatedEffect(this.kind);

  factory SizeGroupsMutatedEffect.fromPaged(PagedMutationKind kind) =>
      SizeGroupsMutatedEffect(kind);

  final PagedMutationKind kind;
}
