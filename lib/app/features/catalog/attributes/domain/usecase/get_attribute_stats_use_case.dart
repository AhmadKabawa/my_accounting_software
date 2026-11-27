import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/base/use_case.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/entity/attribute_stats.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/repositories/attributes_repository.dart';

class GetAttributeStatsUseCase extends UseCase<AttributeStats, NoParams> {
  GetAttributeStatsUseCase(this._repository);
  final AttributesRepository _repository;
  @override
  Future<Either<Failure, AttributeStats>> call(NoParams params) =>
      _repository.getAttributeStats();
}
