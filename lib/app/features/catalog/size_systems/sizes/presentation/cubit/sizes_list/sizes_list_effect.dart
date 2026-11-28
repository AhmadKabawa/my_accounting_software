import 'package:accounting_software/app/core/presentation/state_management/paged_list/paged_list_cubit.dart';

sealed class SizesListEffect {
  const SizesListEffect();
}

class SizesMutatedEffect extends SizesListEffect {
  const SizesMutatedEffect(this.kind);

  factory SizesMutatedEffect.fromPaged(PagedMutationKind kind) =>
      SizesMutatedEffect(kind);

  final PagedMutationKind kind;
}
