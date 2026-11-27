import 'package:accounting_software/app/core/presentation/state_management/paged_list/paged_list_cubit.dart';

sealed class AttributesListEffect {
  const AttributesListEffect();
}

class AttributesMutatedEffect extends AttributesListEffect {
  const AttributesMutatedEffect(this.kind);

  factory AttributesMutatedEffect.fromPaged(PagedMutationKind kind) =>
      AttributesMutatedEffect(kind);

  final PagedMutationKind kind;
}
