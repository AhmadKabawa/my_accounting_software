import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/base/use_case.dart';
import 'package:accounting_software/app/core/foundation/image/image_upload.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/repositories/categories_repository.dart';

class UploadCategoryImageUseCase extends UseCase<String, ImageUpload> {
  UploadCategoryImageUseCase(this._repository);
  final CategoriesRepository _repository;

  @override
  Future<Either<Failure, String>> call(ImageUpload image) =>
      _repository.uploadImage(image);
}
