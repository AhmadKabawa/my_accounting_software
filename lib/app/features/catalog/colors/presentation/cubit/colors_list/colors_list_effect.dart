sealed class ColorsListEffect {
  const ColorsListEffect();
}

enum ColorsMutationKind { created, updated, statusChanged, deleted }

class ColorsMutatedEffect extends ColorsListEffect {
  const ColorsMutatedEffect(this.kind);

  final ColorsMutationKind kind;
}
