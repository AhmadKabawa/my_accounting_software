import 'package:accounting_software/app/core/presentation/state_management/paged_list/paged_list_cubit.dart';

sealed class UnitsListEffect {
  const UnitsListEffect();
}

enum UnitsMutationKind { created, updated, statusChanged, deleted }

class UnitsMutatedEffect extends UnitsListEffect {
  const UnitsMutatedEffect(this.kind);

  factory UnitsMutatedEffect.fromPaged(PagedMutationKind kind) =>
      UnitsMutatedEffect(switch (kind) {
        PagedMutationKind.created => UnitsMutationKind.created,
        PagedMutationKind.updated => UnitsMutationKind.updated,
        PagedMutationKind.statusChanged => UnitsMutationKind.statusChanged,
        PagedMutationKind.deleted => UnitsMutationKind.deleted,
      });

  final UnitsMutationKind kind;
}
