import 'package:equatable/equatable.dart';
import 'package:accounting_software/app/core/presentation/state_management/paged_list/paged_list_state.dart';
import 'package:accounting_software/app/core/presentation/state_management/paged_list/paged_list_cubit.dart';

enum ProductTypeMutationKind { created, updated, statusChanged, deleted }

sealed class ProductTypesListEffect extends Equatable {
  const ProductTypesListEffect();
}

final class ProductTypesMutatedEffect extends ProductTypesListEffect {
  const ProductTypesMutatedEffect(this.kind);

  final ProductTypeMutationKind kind;

  factory ProductTypesMutatedEffect.fromPaged(PagedMutationKind kind) =>
      ProductTypesMutatedEffect(switch (kind) {
        PagedMutationKind.created => ProductTypeMutationKind.created,
        PagedMutationKind.updated => ProductTypeMutationKind.updated,
        PagedMutationKind.statusChanged =>
          ProductTypeMutationKind.statusChanged,
        PagedMutationKind.deleted => ProductTypeMutationKind.deleted,
      });

  @override
  List<Object?> get props => [kind];
}
