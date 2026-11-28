sealed class CareInstructionsListEffect {
  const CareInstructionsListEffect();
}

enum CareInstructionsMutationKind { created, updated, statusChanged, deleted }

class CareInstructionsMutatedEffect extends CareInstructionsListEffect {
  const CareInstructionsMutatedEffect(this.kind);
  final CareInstructionsMutationKind kind;
}
