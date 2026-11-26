sealed class TagsListEffect {
  const TagsListEffect();
}

enum TagsMutationKind { created, updated, statusChanged, deleted }

class TagsMutatedEffect extends TagsListEffect {
  const TagsMutatedEffect(this.kind);

  final TagsMutationKind kind;
}
