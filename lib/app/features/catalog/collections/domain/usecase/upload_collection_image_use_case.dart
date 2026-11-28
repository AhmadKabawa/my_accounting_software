import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/base/use_case.dart';
import 'package:accounting_software/app/core/foundation/image/image_upload.dart';
import 'package:accounting_software/app/features/catalog/collections/domain/repositories/collections_repository.dart';

class UploadCollectionImageUseCase extends UseCase<String, ImageUpload> {
  UploadCollectionImageUseCase(this._repository);
  final CollectionsRepository _repository;

  @override
  Future<Either<Failure, String>> call(ImageUpload image) =>
      _repository.uploadImage(image);
}
