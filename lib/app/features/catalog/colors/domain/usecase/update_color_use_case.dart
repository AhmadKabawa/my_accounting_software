import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/base/use_case.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/entity/catalog_color.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/entity/catalog_color_draft.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/repositories/colors_repository.dart';

class UpdateColorParams extends Equatable {
  const UpdateColorParams({required this.id, required this.draft});
  final int id;
  final CatalogColorDraft draft;

  @override
  List<Object?> get props => [id, draft];
}

class UpdateColorUseCase extends UseCase<CatalogColor, UpdateColorParams> {
  UpdateColorUseCase(this._repository);
  final ColorsRepository _repository;

  @override
  Future<Either<Failure, CatalogColor>> call(UpdateColorParams params) =>
      _repository.updateColor(id: params.id, draft: params.draft);
}
