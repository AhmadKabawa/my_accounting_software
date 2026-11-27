import 'package:dartz/dartz.dart';
import 'package:easy_localization/src/localization.dart';
import 'package:easy_localization/src/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/flash_messages.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/entity/category.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/entity/category_draft.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/entity/category_tree.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/failures/category_failure_keys.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/failures/category_failures.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/usecase/create_category_use_case.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/usecase/update_category_use_case.dart';
import 'package:accounting_software/app/features/catalog/categories/presentation/cubit/category_form/category_form_cubit.dart';
import 'package:accounting_software/app/features/catalog/categories/presentation/cubit/category_form/category_form_effect.dart';

import '../support/fake_categories_repository.dart';

Category _category(int id, {int? parentId, String? name, bool active = true}) =>
    Category(
      id: id,
      parentId: parentId,
      name: name ?? 'Category $id',
      slug: 'category-$id',
      sortOrder: id,
      isActive: active,
      productCount: 0,
    );

CategoryFormCubit _cubit(
  FakeCategoriesRepository repository, {
  Category? category,
  CategoryTree? tree,
}) => CategoryFormCubit(
  createCategory: CreateCategoryUseCase(repository),
  updateCategory: UpdateCategoryUseCase(repository),
  flashMessages: FlashMessages(),
  category: category,
  tree: tree,
);

void main() {
  setUpAll(() {
    Localization.load(
      const Locale('en'),
      translations: Translations({
        'categories.required': 'Required',
        'categories.nameTooLong': 'Name too long',
        'categories.slugTooLong': 'Slug too long',
        'categories.slugFormat': 'Invalid slug',
        'categories.imageFormat': 'Invalid URL',
        'categories.imageTooLong': 'URL too long',
        'categories.sortOrderFormat': 'Invalid order',
        'categoryfailures.slugTaken': 'Slug already used',
        'categories.saved': 'Saved',
      }),
    );
  });

  test('Latin names generate slugs automatically', () async {
    final repository = FakeCategoriesRepository(categories: [_category(1)]);
    final cubit = _cubit(repository);

    cubit.nameChanged('Men Running Shoes');

    expect(cubit.state.slug, 'men-running-shoes');
    expect(cubit.state.slugManuallyEdited, isFalse);
    expect(cubit.state.isValid, isTrue);
    await cubit.close();
  });

  test(
    'Arabic names require a manually entered slug and keep it on rename',
    () async {
      final repository = FakeCategoriesRepository(categories: [_category(1)]);
      final cubit = _cubit(repository);

      cubit.nameChanged('أحذية رجالية');
      expect(cubit.state.slug, isEmpty);
      expect(cubit.state.errorFor('slug'), isNotNull);

      cubit.slugChanged('mens-shoes');
      cubit.nameChanged('أحذية رياضية رجالية');

      expect(cubit.state.slug, 'mens-shoes');
      expect(cubit.state.slugManuallyEdited, isTrue);
      expect(cubit.state.isValid, isTrue);
      await cubit.close();
    },
  );

  test('image accepts HTTP and HTTPS only', () async {
    final repository = FakeCategoriesRepository(categories: [_category(1)]);
    final cubit = _cubit(repository);

    cubit.imageChanged('ftp://cdn.example.test/image.png');
    expect(cubit.state.errorFor('image'), isNotNull);

    cubit.imageChanged('https://cdn.example.test/image.png');
    expect(cubit.state.errorFor('image'), isNull);
    await cubit.close();
  });

  test(
    'parent options include paths and exclude the edited category descendants',
    () async {
      final categories = [
        _category(1),
        _category(2, parentId: 1),
        _category(3, parentId: 2),
        _category(4),
      ];
      final tree = CategoryTree(categories);
      final repository = FakeCategoriesRepository(categories: categories);
      final cubit = _cubit(repository, category: categories[1], tree: tree);

      expect(cubit.parentOptions.map((node) => node.id), [1, 4]);
      expect(cubit.parentOptionLabel(cubit.parentOptions.first), 'Category 1');
      expect(cubit.parentChanged, isFalse);

      cubit.setParent(3);
      expect(cubit.state.parentId, 1);
      cubit.setParent(4);
      expect(cubit.state.parentId, 4);
      expect(cubit.parentChanged, isTrue);
      cubit.reset();
      expect(cubit.state.parentId, 1);
      expect(cubit.parentChanged, isFalse);
      expect(cubit.state.name, 'Category 2');
      await cubit.close();
    },
  );

  test(
    'parent options hide inactive rows except the currently selected parent',
    () async {
      final categories = [
        _category(1),
        _category(2, active: false),
        _category(3, parentId: 2),
        _category(4, active: false),
      ];
      final cubit = _cubit(
        FakeCategoriesRepository(categories: categories),
        category: categories[2],
        tree: CategoryTree(categories),
      );

      expect(cubit.parentOptions.map((node) => node.id), [1, 2]);
      cubit.setParent(1);
      expect(cubit.parentOptions.map((node) => node.id), [1]);
      await cubit.close();
    },
  );

  test('duplicate sibling name is a non-blocking warning condition', () async {
    final categories = [
      _category(1),
      _category(2, parentId: 1, name: 'Sport'),
      _category(3, parentId: 1, name: 'Sports'),
    ];
    final cubit = _cubit(
      FakeCategoriesRepository(categories: categories),
      category: categories[2],
      tree: CategoryTree(categories),
    );

    cubit.nameChanged(' sport ');
    expect(cubit.hasSiblingNameConflict, isTrue);
    expect(cubit.state.isValid, isTrue);
    cubit.nameChanged('Athletics');
    expect(cubit.hasSiblingNameConflict, isFalse);
    await cubit.close();
  });

  test('save emits success and returns to idle', () async {
    final repository = FakeCategoriesRepository(categories: [_category(1)]);
    final cubit = _cubit(repository);
    final effects = <CategoryFormEffect>[];
    final subscription = cubit.effectStream.listen(effects.add);

    cubit.nameChanged('Men Shoes');
    await cubit.save();
    await Future<void>.delayed(Duration.zero);

    expect(repository.createCalls, 1);
    expect(effects.single, isA<CategorySavedEffect>());
    expect(cubit.state.saving, isFalse);
    await subscription.cancel();
    await cubit.close();
  });

  test(
    'duplicate slug is attached to the slug field as a save failure',
    () async {
      final repository = FakeCategoriesRepository(categories: [_category(1)])
        ..createResult = const Left(CategorySlugTakenFailure());
      final cubit = _cubit(repository);
      final effects = <CategoryFormEffect>[];
      final subscription = cubit.effectStream.listen(effects.add);

      cubit.nameChanged('Men Shoes');
      await cubit.save();
      await Future<void>.delayed(Duration.zero);

      expect(effects.single, isA<CategorySaveFailedEffect>());
      expect(
        (effects.single as CategorySaveFailedEffect).messageKey,
        CategoryFailureKeys.slugTaken,
      );
      expect(cubit.state.errorFor('slug'), isNotNull);
      expect(cubit.state.saving, isFalse);
      await subscription.cancel();
      await cubit.close();
    },
  );

  test('invalid form does not call the repository', () async {
    final repository = FakeCategoriesRepository(categories: [_category(1)]);
    final cubit = _cubit(repository);

    await cubit.save();

    expect(repository.createCalls, 0);
    expect(cubit.state.errorFor('name'), isNotNull);
    expect(cubit.state.errorFor('slug'), isNotNull);
    await cubit.close();
  });
  test(
    'new and duplicate categories send their selected active state',
    () async {
      final repository = FakeCategoriesRepository(categories: [_category(1)]);
      final seed = CategoryDraft(
        parentId: 1,
        name: 'Sport Copy',
        slug: 'sport-copy',
        isActive: false,
      );
      final cubit = CategoryFormCubit(
        createCategory: CreateCategoryUseCase(repository),
        updateCategory: UpdateCategoryUseCase(repository),
        flashMessages: FlashMessages(),
        seed: seed,
        tree: CategoryTree(repository.categories),
      );

      await cubit.save();

      expect(repository.createCalls, 1);
      expect(repository.updateCalls, 0);
      expect(repository.lastCreatedDraft?.parentId, 1);
      expect(repository.lastCreatedDraft?.isActive, isFalse);
      await cubit.close();
    },
  );

  test(
    'PATCH omits unchanged status and sends it only after a change',
    () async {
      final category = _category(1);
      final repository = FakeCategoriesRepository(categories: [category]);
      final cubit = _cubit(
        repository,
        category: category,
        tree: CategoryTree([category]),
      );

      cubit.nameChanged('Updated Shoes');
      await cubit.save();
      expect(repository.lastUpdatedDraft?.isActive, isNull);

      cubit.setActive(false);
      await cubit.save();
      expect(repository.lastUpdatedDraft?.isActive, isFalse);
      await cubit.close();
    },
  );
}
