sealed class BrandsListEffect {
  const BrandsListEffect();
}

enum BrandsMutationKind { created, updated, statusChanged, deleted }

class BrandsMutatedEffect extends BrandsListEffect {
  const BrandsMutatedEffect(this.kind);

  final BrandsMutationKind kind;
}
