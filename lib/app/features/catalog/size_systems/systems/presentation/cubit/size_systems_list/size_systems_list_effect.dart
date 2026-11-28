import 'package:accounting_software/app/core/presentation/state_management/paged_list/paged_list_cubit.dart';

sealed class SizeSystemsListEffect {
  const SizeSystemsListEffect();
}

class SizeSystemsMutatedEffect extends SizeSystemsListEffect {
  const SizeSystemsMutatedEffect(this.kind);

  factory SizeSystemsMutatedEffect.fromPaged(PagedMutationKind kind) =>
      SizeSystemsMutatedEffect(kind);

  final PagedMutationKind kind;
}
