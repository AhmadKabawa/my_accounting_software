import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/image/image_upload.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/entity/category.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/entity/category_draft.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/repositories/categories_repository.dart';

class FakeCategoriesRepository implements CategoriesRepository {
  FakeCategoriesRepository({this.categories = const []});

  List<Category> categories;
  int getAllCalls = 0;
  int createCalls = 0;
  int updateCalls = 0;
  final List<int> deletedIds = [];
  final List<(int, bool)> statusUpdates = [];
  Either<Failure, Unit> mutationResult = const Right(unit);
  Either<Failure, Category>? createResult;
  Either<Failure, Category>? updateResult;
  CategoryDraft? lastCreatedDraft;
  CategoryDraft? lastUpdatedDraft;
  int uploadCalls = 0;
  Either<Failure, String>? uploadImageResult;

  @override
  Future<Either<Failure, List<Category>>> getAll() async {
    getAllCalls++;
    return Right(categories);
  }

  @override
  Future<Either<Failure, Category>> create(CategoryDraft draft) async {
    createCalls++;
    lastCreatedDraft = draft;
    if (createResult != null) return createResult!;
    final nextId =
        categories.fold<int>(
          0,
          (maxId, item) => item.id > maxId ? item.id : maxId,
        ) +
        1;
    final created = Category(
      id: nextId,
      parentId: draft.parentId,
      name: draft.name,
      slug: draft.slug,
      description: draft.description,
      image: draft.image,
      sortOrder: draft.sortOrder,
      isActive: draft.isActive ?? true,
      productCount: 0,
    );
    categories = [...categories, created];
    return Right(created);
  }

  @override
  Future<Either<Failure, Category>> update({
    required int id,
    required CategoryDraft draft,
  }) async {
    updateCalls++;
    lastUpdatedDraft = draft;
    return updateResult ??
        Right(categories.firstWhere((item) => item.id == id));
  }

  @override
  Future<Either<Failure, Unit>> delete(int id) async {
    deletedIds.add(id);
    return mutationResult;
  }

  @override
  Future<Either<Failure, String>> uploadImage(ImageUpload image) async {
    uploadCalls++;
    return uploadImageResult ??
        const Right('https://cdn.example.test/categories/image.webp');
  }

  @override
  Future<Either<Failure, Unit>> setActive({
    required int id,
    required bool isActive,
  }) async {
    statusUpdates.add((id, isActive));
    return mutationResult;
  }
}
