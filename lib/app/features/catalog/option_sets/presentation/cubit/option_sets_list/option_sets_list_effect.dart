import 'package:accounting_software/app/core/presentation/state_management/paged_list/paged_list_cubit.dart';

sealed class OptionSetsListEffect {
  const OptionSetsListEffect();
}

class OptionSetsMutatedEffect extends OptionSetsListEffect {
  const OptionSetsMutatedEffect(this.kind);

  factory OptionSetsMutatedEffect.fromPaged(PagedMutationKind kind) =>
      OptionSetsMutatedEffect(kind);

  final PagedMutationKind kind;
}
