import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/base/use_case.dart';
import 'package:accounting_software/app/features/catalog/genders/domain/entity/gender.dart';
import 'package:accounting_software/app/features/catalog/genders/domain/entity/gender_draft.dart';
import 'package:accounting_software/app/features/catalog/genders/domain/repositories/genders_repository.dart';

class CreateGenderUseCase extends UseCase<Gender, GenderDraft> {
  CreateGenderUseCase(this._repo);
  final GendersRepository _repo;
  @override
  Future<Either<Failure, Gender>> call(GenderDraft p) => _repo.createGender(p);
}
