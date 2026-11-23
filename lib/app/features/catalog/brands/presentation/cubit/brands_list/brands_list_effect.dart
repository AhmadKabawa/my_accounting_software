import 'package:accounting_software/app/core/presentation/state_management/paged_list/paged_list_cubit.dart';

sealed class BrandsListEffect {
  const BrandsListEffect();
}

enum BrandsMutationKind { created, updated, statusChanged, deleted }

class BrandsMutatedEffect extends BrandsListEffect {
  const BrandsMutatedEffect(this.kind);

  factory BrandsMutatedEffect.fromPaged(PagedMutationKind kind) =>
      BrandsMutatedEffect(switch (kind) {
        PagedMutationKind.created => BrandsMutationKind.created,
        PagedMutationKind.updated => BrandsMutationKind.updated,
        PagedMutationKind.statusChanged => BrandsMutationKind.statusChanged,
        PagedMutationKind.deleted => BrandsMutationKind.deleted,
      });

  final BrandsMutationKind kind;
}
