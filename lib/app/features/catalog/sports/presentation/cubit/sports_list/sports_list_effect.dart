sealed class SportsListEffect {
  const SportsListEffect();
}

enum SportsMutationKind { created, updated, statusChanged, deleted }

class SportsMutatedEffect extends SportsListEffect {
  const SportsMutatedEffect(this.kind);

  final SportsMutationKind kind;
}
