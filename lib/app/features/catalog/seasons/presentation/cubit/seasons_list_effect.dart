sealed class SeasonsListEffect {
  const SeasonsListEffect();
}

enum SeasonsMutationKind { created, updated, statusChanged, deleted }

class SeasonsMutatedEffect extends SeasonsListEffect {
  const SeasonsMutatedEffect(this.kind);
  final SeasonsMutationKind kind;
}
