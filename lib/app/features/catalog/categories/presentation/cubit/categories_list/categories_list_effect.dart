sealed class CategoriesListEffect {
  const CategoriesListEffect();
}

enum CategoriesMutationKind { created, updated, statusChanged, deleted }

class CategoriesMutatedEffect extends CategoriesListEffect {
  const CategoriesMutatedEffect(this.kind);

  final CategoriesMutationKind kind;
}
