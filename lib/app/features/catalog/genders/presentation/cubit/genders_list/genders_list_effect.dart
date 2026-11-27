import 'package:accounting_software/app/core/presentation/state_management/paged_list/paged_list_cubit.dart';

sealed class GendersListEffect {
  const GendersListEffect();
}

class GendersMutatedEffect extends GendersListEffect {
  const GendersMutatedEffect(this.kind);

  factory GendersMutatedEffect.fromPaged(PagedMutationKind kind) =>
      GendersMutatedEffect(kind);

  final PagedMutationKind kind;
}
