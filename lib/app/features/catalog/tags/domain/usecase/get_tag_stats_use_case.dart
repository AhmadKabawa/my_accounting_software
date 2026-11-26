import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/base/use_case.dart';
import 'package:accounting_software/app/features/catalog/tags/domain/entity/tag_stats.dart';
import 'package:accounting_software/app/features/catalog/tags/domain/repositories/tags_repository.dart';

class GetTagStatsUseCase extends UseCase<TagStats, NoParams> {
  GetTagStatsUseCase(this._repository);

  final TagsRepository _repository;

  @override
  Future<Either<Failure, TagStats>> call(NoParams params) =>
      _repository.getTagStats();
}
