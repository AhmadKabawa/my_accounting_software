import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/base/use_case.dart';
import 'package:accounting_software/app/features/catalog/collections/domain/entity/collection_draft.dart';
import 'package:accounting_software/app/features/catalog/collections/domain/entity/collection.dart';
import 'package:accounting_software/app/features/catalog/collections/domain/repositories/collections_repository.dart';

class CreateCollectionUseCase extends UseCase<CatalogCollection, CollectionDraft> {
  CreateCollectionUseCase(this._r);
  final CollectionsRepository _r;
  @override
  Future<Either<Failure, CatalogCollection>> call(CollectionDraft p) =>
      _r.createCollection(p);
}
