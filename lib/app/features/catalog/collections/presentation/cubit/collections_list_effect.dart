sealed class CollectionsListEffect {
  const CollectionsListEffect();
}

enum CollectionsMutationKind { created, updated, statusChanged, deleted }

class CollectionsMutatedEffect extends CollectionsListEffect {
  const CollectionsMutatedEffect(this.kind);
  final CollectionsMutationKind kind;
}
