sealed class MaterialsListEffect {
  const MaterialsListEffect();
}

enum MaterialsMutationKind { created, updated, statusChanged, deleted }

class MaterialsMutatedEffect extends MaterialsListEffect {
  const MaterialsMutatedEffect(this.kind);
  final MaterialsMutationKind kind;
}
