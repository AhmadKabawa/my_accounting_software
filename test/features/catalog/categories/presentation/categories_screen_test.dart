import 'package:dartz/dartz.dart';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/access/cubit/access_cubit.dart';
import 'package:accounting_software/app/core/access/domain/access_repository.dart';
import 'package:accounting_software/app/core/access/domain/get_my_access_usecase.dart';
import 'package:accounting_software/app/core/access/models/access_snapshot.dart';
import 'package:accounting_software/app/core/access/permissions.dart';
import 'package:accounting_software/app/core/platform/image_picker/image_picker_port.dart';
import 'package:accounting_software/app/core/localization/keys/image_keys.dart';
import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/localization/keys/catalog_ui_keys.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_page_template/app_page_templates.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text_field/app_text_field.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/flash_messages.dart';
import 'package:accounting_software/app/core/storage/shared_preferences/app_settings_manager.dart';
import 'package:accounting_software/app/features/catalog/categories/di/categories_di.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/entity/category.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/entity/category_draft.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/entity/category_list_query.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/usecase/create_category_use_case.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/usecase/delete_category_use_case.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/usecase/get_categories_use_case.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/usecase/set_category_active_use_case.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/usecase/update_category_use_case.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/usecase/upload_category_image_use_case.dart';
import 'package:accounting_software/app/features/catalog/categories/presentation/cubit/categories_list/categories_list_cubit.dart';
import 'package:accounting_software/app/features/catalog/categories/presentation/cubit/category_form/category_form_cubit.dart';
import 'package:accounting_software/app/features/catalog/categories/presentation/localization/categories_keys.dart';
import 'package:accounting_software/app/features/catalog/categories/presentation/categories_list_page.dart';
import 'package:accounting_software/app/features/catalog/categories/presentation/dialogs/category_duplicate_seed.dart';
import '../../../../helpers/localized_app.dart';
import '../../../../helpers/memory_storage.dart';
import '../support/fake_categories_repository.dart';

class _ImagePicker implements ImagePickerPort {
  _ImagePicker(this.image);
  final PickedImage image;

  @override
  Future<PickedImage?> pickImage() async => image;
}

class _AccessRepository implements AccessRepository {
  _AccessRepository({this.canManage = true});
  final bool canManage;
  @override
  Future<Either<Failure, AccessSnapshot>> getMyAccess() async => Right(
    AccessSnapshot(
      userId: 'categories-screen-test',
      username: 'categories-screen-test',
      email: null,
      isSuperAdmin: false,
      roles: const [],
      permissions: canManage ? {Permissions.masterData.manage} : const {},
      branches: const [],
      warehouses: const [],
      posTerminals: const [],
    ),
  );
}

Category _category(
  int id, {
  int? parentId,
  String? name,
  bool active = true,
  int? products = 0,
}) => Category(
  id: id,
  parentId: parentId,
  name: name ?? 'Category $id',
  slug: 'category-$id',
  sortOrder: id,
  isActive: active,
  productCount: products,
);

List<Category> _sampleCategories() => [
  _category(1, name: 'Root'),
  _category(2, parentId: 1, name: 'Child'),
  _category(3, parentId: 2, name: 'Grandchild'),
  _category(4, name: 'Inactive root', active: false),
  for (var id = 5; id <= 14; id++)
    _category(
      id,
      parentId: id == 5 ? 1 : id - 1,
      name: id == 14 ? 'Deep leaf' : 'Level $id',
    ),
];

void _register(
  FakeCategoriesRepository repository, {
  ImagePickerPort? imagePicker,
}) {
  sl.registerFactory<AppSettingsManager>(
    () => AppSettingsManager(storage: MemoryStorage()),
  );
  sl.registerFactory<FlashMessages>(FlashMessages.new);
  sl.registerLazySingleton<UploadCategoryImageUseCase>(
    () => UploadCategoryImageUseCase(repository),
  );
  if (imagePicker != null) {
    sl.registerSingleton<ImagePickerPort>(imagePicker);
  }
  sl.registerFactory<CategoriesListCubit>(
    () => CategoriesListCubit(
      getCategories: GetCategoriesUseCase(repository),
      setCategoryActive: SetCategoryActiveUseCase(repository),
      deleteCategory: DeleteCategoryUseCase(repository),
      flashMessages: sl<FlashMessages>(),
    ),
  );
  sl.registerFactoryParam<CategoryFormCubit, CategoryFormArgs, void>(
    (args, _) => CategoryFormCubit(
      createCategory: CreateCategoryUseCase(repository),
      updateCategory: UpdateCategoryUseCase(repository),
      flashMessages: sl<FlashMessages>(),
      category: args.category,
      seed: args.seed,
      tree: args.tree,
      initialParentId: args.initialParentId,
    ),
  );
}

Widget _home({bool canManage = true}) => BlocProvider<AccessCubit>(
  create: (_) => AccessCubit(
    getMyAccess: GetMyAccessUseCase(_AccessRepository(canManage: canManage)),
  )..load(),
  child: const Scaffold(body: CategoriesListPage()),
);

CategoriesListCubit _listCubit(WidgetTester tester) =>
    BlocProvider.of<CategoriesListCubit>(
      tester.element(find.byType(ListPageTemplate)),
    );

Finder _categoryNameInput() => find.descendant(
  of: find.byWidgetPredicate(
    (widget) =>
        widget is AppTextField &&
        widget.labelKey == CategoriesKeys.categoryName,
  ),
  matching: find.byType(TextField),
);

void main() {
  setUpAll(() => useTranslations(const Locale('en')));
  tearDown(() async => sl.reset());

  testWidgets('status filters and search stay safe in the full list page', (
    tester,
  ) async {
    final repository = FakeCategoriesRepository(
      categories: _sampleCategories(),
    );
    _register(repository);
    setScreenSize(tester, const Size(360, 800));
    await tester.pumpWidget(
      buildTestApp(home: _home(), direction: TextDirection.rtl),
    );
    await tester.pumpAndSettle();

    final cubit = _listCubit(tester);
    await cubit.setStatus(CategoryStatusFilter.active);
    await tester.pumpAndSettle();
    expect(
      cubit.state.result!.items.every((row) => row.category.isActive),
      isTrue,
    );

    await cubit.setStatus(CategoryStatusFilter.inactive);
    await tester.pumpAndSettle();
    expect(
      cubit.state.result!.items.every((row) => !row.category.isActive),
      isTrue,
    );

    await cubit.setStatus(CategoryStatusFilter.all);
    await tester.enterText(find.byType(TextField).first, 'Child');
    await tester.pumpAndSettle();
    expect(cubit.state.result!.items.every((row) => row.flat), isTrue);
    expect(find.textContaining('Root › Child'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('full list page renders at 1200 in RTL and LTR', (tester) async {
    _register(FakeCategoriesRepository(categories: _sampleCategories()));
    for (final direction in [TextDirection.rtl, TextDirection.ltr]) {
      setScreenSize(tester, const Size(1200, 900));
      await tester.pumpWidget(
        buildTestApp(home: _home(), direction: direction),
      );
      await tester.pumpAndSettle();
      expect(find.byType(CategoriesListPage), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      await sl.reset();
      _register(FakeCategoriesRepository(categories: _sampleCategories()));
    }
  });

  testWidgets('search field retains readable width at 360 without overflow', (
    tester,
  ) async {
    _register(FakeCategoriesRepository(categories: _sampleCategories()));
    setScreenSize(tester, const Size(360, 800));
    await tester.pumpWidget(
      buildTestApp(home: _home(), direction: TextDirection.ltr),
    );
    await tester.pumpAndSettle();

    final search = find.byType(AppTextField).first;
    expect(tester.getSize(search).width, greaterThanOrEqualTo(180));
    expect(tester.takeException(), isNull);
  });

  testWidgets('tree toolbar toggles expansion without clearing search', (
    tester,
  ) async {
    _register(FakeCategoriesRepository(categories: _sampleCategories()));
    await tester.pumpWidget(
      buildTestApp(home: _home(), direction: TextDirection.ltr),
    );
    await tester.pumpAndSettle();
    final cubit = _listCubit(tester);
    cubit.searchChanged('Child');
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip(CategoriesKeys.expandAll.en));
    await tester.pumpAndSettle();
    expect(cubit.state.query.search, 'Child');
    await tester.tap(find.byTooltip(CategoriesKeys.collapseAll.en));
    await tester.pumpAndSettle();
    expect(cubit.state.query.search, 'Child');
    expect(tester.takeException(), isNull);
  });

  testWidgets('changing filters clears the bulk selection projection', (
    tester,
  ) async {
    _register(FakeCategoriesRepository(categories: _sampleCategories()));
    await tester.pumpWidget(
      buildTestApp(home: _home(), direction: TextDirection.ltr),
    );
    await tester.pumpAndSettle();
    final cubit = _listCubit(tester);
    cubit.selection.selectPage(cubit.state.result!.items.map((row) => row.id));
    expect(cubit.selection.state, isNotEmpty);

    await cubit.setStatus(CategoryStatusFilter.inactive);
    await tester.pumpAndSettle();
    expect(cubit.selection.state, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('deep search path renders at 360 in RTL and LTR', (tester) async {
    _register(FakeCategoriesRepository(categories: _sampleCategories()));
    for (final direction in [TextDirection.rtl, TextDirection.ltr]) {
      setScreenSize(tester, const Size(360, 800));
      await tester.pumpWidget(
        buildTestApp(home: _home(), direction: direction),
      );
      await tester.pumpAndSettle();
      _listCubit(tester).searchChanged('Deep leaf');
      await tester.pumpAndSettle();
      expect(find.textContaining('Root ›'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      await sl.reset();
      _register(FakeCategoriesRepository(categories: _sampleCategories()));
    }
  });

  testWidgets('adding a subcategory saves once and reloads the tree', (
    tester,
  ) async {
    final repository = FakeCategoriesRepository(
      categories: [
        _category(1, name: 'Root'),
        _category(2, parentId: 1, name: 'Existing child'),
      ],
    );
    _register(repository);
    await tester.pumpWidget(
      buildTestApp(home: _home(), direction: TextDirection.ltr),
    );
    await tester.pumpAndSettle();
    _listCubit(tester).collapseAll();
    await tester.pumpAndSettle();

    final rootActions = find.byTooltip(CatalogUiKeys.moreActions.en).first;
    await tester.ensureVisible(rootActions);
    await tester.pumpAndSettle();
    await tester.tap(rootActions);
    await tester.pumpAndSettle();
    await tester.tap(find.text(CategoriesKeys.addChild.en));
    await tester.pumpAndSettle();

    await tester.enterText(_categoryNameInput(), 'New child');
    await tester.pumpAndSettle();
    await tester.tap(find.text(CategoriesKeys.save.en));
    await tester.pumpAndSettle();

    expect(repository.createCalls, 1);
    expect(
      repository.categories.any(
        (item) => item.name == 'New child' && item.parentId == 1,
      ),
      isTrue,
    );
    expect(_listCubit(tester).tree!.byId(3)?.name, 'New child');
    expect(tester.takeException(), isNull);
    expect(repository.getAllCalls, 2);
  });

  testWidgets('adding a subcategory to a leaf uses the same editor flow', (
    tester,
  ) async {
    final repository = FakeCategoriesRepository(
      categories: _sampleCategories().take(3).toList(),
    );
    _register(repository);
    setScreenSize(tester, const Size(360, 800));
    await tester.pumpWidget(
      buildTestApp(home: _home(), direction: TextDirection.ltr),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'initial page');
    _listCubit(tester).expandAll();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'after expanding the tree');

    final leafActions = find.byTooltip(CatalogUiKeys.moreActions.en).at(2);
    await tester.ensureVisible(leafActions);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'after scrolling to leaf');
    await tester.tap(leafActions);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'after opening row actions');
    await tester.tap(find.text(CategoriesKeys.addChild.en));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'after opening editor');

    await tester.enterText(_categoryNameInput(), 'Leaf child');
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'after entering the name');
    await tester.tap(find.text(CategoriesKeys.save.en));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'after saving the child');

    expect(repository.createCalls, 1);
    expect(
      repository.categories.any(
        (item) => item.name == 'Leaf child' && item.parentId == 3,
      ),
      isTrue,
    );
    expect(repository.getAllCalls, 2);
    expect(_listCubit(tester).tree!.byId(4)?.name, 'Leaf child');
    expect(tester.takeException(), isNull);
  });

  testWidgets('adding a root category saves once and reloads the tree', (
    tester,
  ) async {
    setScreenSize(tester, const Size(1200, 900));
    final repository = FakeCategoriesRepository(categories: [_category(1)]);
    _register(repository);
    await tester.pumpWidget(
      buildTestApp(home: _home(), direction: TextDirection.ltr),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text(CategoriesKeys.add.en).first);
    await tester.pumpAndSettle();
    await tester.enterText(_categoryNameInput(), 'New root');
    await tester.pumpAndSettle();
    await tester.tap(find.text(CategoriesKeys.save.en));
    await tester.pumpAndSettle();

    expect(repository.createCalls, 1);
    expect(repository.getAllCalls, 2);
    expect(
      repository.categories.any(
        (item) => item.name == 'New root' && item.parentId == null,
      ),
      isTrue,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('parent row hides the standard delete action', (tester) async {
    setScreenSize(tester, const Size(1200, 900));
    _register(
      FakeCategoriesRepository(
        categories: _sampleCategories().take(3).toList(),
      ),
    );
    await tester.pumpWidget(
      buildTestApp(home: _home(), direction: TextDirection.ltr),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip(CatalogUiKeys.moreActions.en).first);
    await tester.pumpAndSettle();

    expect(find.text(CategoriesKeys.delete.en), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('desktop row action menu stays within its popup width', (
    tester,
  ) async {
    setScreenSize(tester, const Size(1200, 900));
    _register(
      FakeCategoriesRepository(
        categories: _sampleCategories().take(3).toList(),
      ),
    );
    await tester.pumpWidget(
      buildTestApp(home: _home(), direction: TextDirection.ltr),
    );
    await tester.pumpAndSettle();
    _listCubit(tester).expandAll();
    await tester.pumpAndSettle();

    final leafActions = find.byTooltip(CatalogUiKeys.moreActions.en).at(2);
    await tester.tap(leafActions);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
  testWidgets('category editor uploads a selected image and saves its URL', (
    tester,
  ) async {
    final repository = FakeCategoriesRepository(categories: []);
    _register(
      repository,
      imagePicker: _ImagePicker(
        PickedImage(
          bytes: Uint8List.fromList([
            0x89,
            0x50,
            0x4e,
            0x47,
            0x0d,
            0x0a,
            0x1a,
            0x0a,
          ]),
          fileName: 'category.png',
          mimeType: 'image/png',
        ),
      ),
    );
    setScreenSize(tester, const Size(360, 800));
    await tester.pumpWidget(
      buildTestApp(home: _home(), direction: TextDirection.rtl),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text(CategoriesKeys.add.en).first);
    await tester.pumpAndSettle();
    final uploadButton = find.bySemanticsLabel(CategoriesKeys.uploadImage.en);
    await tester.ensureVisible(uploadButton);
    await tester.pumpAndSettle();
    await tester.tap(uploadButton);
    await tester.pumpAndSettle();

    expect(repository.uploadCalls, 1);
    await tester.enterText(_categoryNameInput(), 'Photo category');
    await tester.pumpAndSettle();
    await tester.tap(find.text(CategoriesKeys.save.en));
    await tester.pumpAndSettle();

    expect(
      repository.lastCreatedDraft?.image,
      'https://cdn.example.test/categories/image.webp',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('category image upload shows a clear Storage permission error', (
    tester,
  ) async {
    final repository = FakeCategoriesRepository()
      ..uploadImageResult = const Left(PermissionFailure());
    _register(
      repository,
      imagePicker: _ImagePicker(
        PickedImage(
          bytes: Uint8List.fromList([
            0x89,
            0x50,
            0x4e,
            0x47,
            0x0d,
            0x0a,
            0x1a,
            0x0a,
          ]),
          fileName: 'category.png',
          mimeType: 'image/png',
        ),
      ),
    );
    await tester.pumpWidget(
      buildTestApp(home: _home(), direction: TextDirection.ltr),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text(CategoriesKeys.add.en).first);
    await tester.pumpAndSettle();
    final uploadButton = find.bySemanticsLabel(CategoriesKeys.uploadImage.en);
    await tester.ensureVisible(uploadButton);
    await tester.pumpAndSettle();
    await tester.tap(uploadButton);
    await tester.pumpAndSettle();

    expect(repository.uploadCalls, 1);
    expect(find.text(CategoriesKeys.imageUploadPermission.en), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('category image upload rejects files larger than five MB', (
    tester,
  ) async {
    final repository = FakeCategoriesRepository();
    _register(
      repository,
      imagePicker: _ImagePicker(
        PickedImage(
          bytes: Uint8List(5 * 1024 * 1024 + 1),
          fileName: 'large.png',
          mimeType: 'image/png',
        ),
      ),
    );
    await tester.pumpWidget(
      buildTestApp(home: _home(), direction: TextDirection.ltr),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text(CategoriesKeys.add.en).first);
    await tester.pumpAndSettle();
    final uploadButton = find.bySemanticsLabel(CategoriesKeys.uploadImage.en);
    await tester.ensureVisible(uploadButton);
    await tester.pumpAndSettle();
    await tester.tap(uploadButton);
    await tester.pumpAndSettle();

    expect(repository.uploadCalls, 0);
    expect(find.text(ImageKeys.tooLarge.en), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'statistics apply their local filters without a network request',
    (tester) async {
      final repository = FakeCategoriesRepository(
        categories: _sampleCategories(),
      );
      _register(repository);
      await tester.pumpWidget(
        buildTestApp(home: _home(), direction: TextDirection.ltr),
      );
      await tester.pumpAndSettle();
      final before = repository.getAllCalls;

      await tester.tap(find.text(CategoriesKeys.activeCategories.en).first);
      await tester.pumpAndSettle();

      expect(
        _listCubit(tester).state.query.status,
        CategoryStatusFilter.active,
      );
      expect(repository.getAllCalls, before);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'desktop row opens side details panel and child navigation works',
    (tester) async {
      setScreenSize(tester, const Size(1200, 900));
      _register(
        FakeCategoriesRepository(
          categories: _sampleCategories().take(4).toList(),
        ),
      );
      await tester.pumpWidget(
        buildTestApp(home: _home(), direction: TextDirection.ltr),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Root').first);
      await tester.pumpAndSettle();
      expect(find.text(CategoriesKeys.details.en), findsOneWidget);
      expect(find.text('Child'), findsWidgets);

      await tester.ensureVisible(find.text('Child').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Child').last);
      await tester.pumpAndSettle();
      expect(find.text('Grandchild'), findsWidgets);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('mobile card opens details bottom sheet without overflow', (
    tester,
  ) async {
    setScreenSize(tester, const Size(360, 800));
    _register(
      FakeCategoriesRepository(
        categories: _sampleCategories().take(3).toList(),
      ),
    );
    await tester.pumpWidget(
      buildTestApp(home: _home(), direction: TextDirection.rtl),
    );
    await tester.pumpAndSettle();

    expect(find.text('Root › Child'), findsOneWidget);
    await tester.tap(find.text('Root').first);
    await tester.pumpAndSettle();

    expect(find.text(CategoriesKeys.details.en), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('read-only users see no write actions in rows or details', (
    tester,
  ) async {
    setScreenSize(tester, const Size(1200, 900));
    _register(
      FakeCategoriesRepository(
        categories: _sampleCategories().take(3).toList(),
      ),
    );
    await tester.pumpWidget(
      buildTestApp(home: _home(canManage: false), direction: TextDirection.ltr),
    );
    await tester.pumpAndSettle();

    expect(find.byTooltip(CatalogUiKeys.moreActions.en), findsNothing);
    await tester.tap(find.text('Root').first);
    await tester.pumpAndSettle();

    expect(find.text(CategoriesKeys.details.en), findsOneWidget);
    expect(find.byTooltip(CategoriesKeys.edit.en), findsNothing);
    expect(find.byTooltip(CategoriesKeys.addChild.en), findsNothing);
    expect(find.byTooltip(CategoriesKeys.activate.en), findsNothing);
    expect(find.byTooltip(CategoriesKeys.deactivate.en), findsNothing);
    expect(find.byTooltip(CategoriesKeys.duplicate.en), findsNothing);
    expect(find.byTooltip(CategoriesKeys.delete.en), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Tab reaches a category row and Enter opens its details', (
    tester,
  ) async {
    setScreenSize(tester, const Size(1200, 900));
    _register(
      FakeCategoriesRepository(
        categories: _sampleCategories().take(3).toList(),
      ),
    );
    await tester.pumpWidget(
      buildTestApp(home: _home(), direction: TextDirection.ltr),
    );
    await tester.pumpAndSettle();

    final rowFocus = Focus.of(
      tester.element(find.text('Root').first),
      scopeOk: false,
    );
    for (
      var i = 0;
      i < 40 && FocusManager.instance.primaryFocus != rowFocus;
      i++
    ) {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
    }
    expect(FocusManager.instance.primaryFocus, same(rowFocus));

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.text(CategoriesKeys.details.en), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('editor dialog closes with Escape', (tester) async {
    setScreenSize(tester, const Size(1200, 900));
    _register(FakeCategoriesRepository(categories: []));
    await tester.pumpWidget(
      buildTestApp(home: _home(), direction: TextDirection.ltr),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text(CategoriesKeys.add.en).first);
    await tester.pumpAndSettle();
    expect(find.text(CategoriesKeys.categoryName.en), findsOneWidget);
    expect(find.text(CategoriesKeys.activeOnCreate.en), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text(CategoriesKeys.categoryName.en), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('details panel closes with Escape', (tester) async {
    setScreenSize(tester, const Size(1200, 900));
    _register(
      FakeCategoriesRepository(
        categories: _sampleCategories().take(3).toList(),
      ),
    );
    await tester.pumpWidget(
      buildTestApp(home: _home(), direction: TextDirection.ltr),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Root').first);
    await tester.pumpAndSettle();
    expect(find.text(CategoriesKeys.details.en), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text(CategoriesKeys.details.en), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('level and usage filters are local on the full page', (
    tester,
  ) async {
    setScreenSize(tester, const Size(360, 800));
    final repository = FakeCategoriesRepository(
      categories: [
        _category(1, name: 'Root with products', products: 2),
        _category(2, parentId: 1, name: 'Leaf without products', products: 0),
        _category(3, name: 'Unknown root', products: null),
      ],
    );
    _register(repository);
    await tester.pumpWidget(
      buildTestApp(home: _home(), direction: TextDirection.rtl),
    );
    await tester.pumpAndSettle();
    final before = repository.getAllCalls;

    _listCubit(tester).setLevel(CategoryLevelFilter.roots);
    await tester.pumpAndSettle();
    expect(_listCubit(tester).state.result!.items.map((node) => node.id), [
      1,
      3,
    ]);

    _listCubit(tester).setLevel(CategoryLevelFilter.leaves);
    await tester.pumpAndSettle();
    expect(_listCubit(tester).state.result!.items.map((node) => node.id), [
      2,
      3,
    ]);

    _listCubit(tester).setUsage(CategoryUsageFilter.withProducts);
    await tester.pumpAndSettle();
    expect(_listCubit(tester).state.result!.items.map((node) => node.id), [1]);

    _listCubit(tester).setUsage(CategoryUsageFilter.withoutProducts);
    await tester.pumpAndSettle();
    expect(_listCubit(tester).state.result!.items.map((node) => node.id), [2]);
    expect(repository.getAllCalls, before);
    expect(tester.takeException(), isNull);
  });

  testWidgets('duplicate seed preserves parent and generates a fresh slug', (
    tester,
  ) async {
    final source = _category(2, parentId: 1, name: 'Sport', active: false);
    CategoryDraft? seed;
    await tester.pumpWidget(
      buildTestApp(
        home: Builder(
          builder: (context) {
            seed = categoryDuplicateSeed(context, source);
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(seed?.parentId, 1);
    expect(seed?.name, 'Sport Copy');
    expect(seed?.slug, 'sport-copy');
    expect(seed?.isActive, isFalse);
  });

  testWidgets('details panel edit then add-child uses the shared editor flow', (
    tester,
  ) async {
    setScreenSize(tester, const Size(1200, 900));
    final repository = FakeCategoriesRepository(
      categories: _sampleCategories().take(3).toList(),
    );
    _register(repository);
    await tester.pumpWidget(
      buildTestApp(home: _home(), direction: TextDirection.ltr),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Root').first);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip(CategoriesKeys.edit.en));
    await tester.pumpAndSettle();
    expect(find.text(CategoriesKeys.active.en), findsOneWidget);
    await tester.enterText(_categoryNameInput(), 'Root Updated');
    await tester.tap(find.text(CategoriesKeys.save.en));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip(CategoriesKeys.addChild.en));
    await tester.pumpAndSettle();
    await tester.enterText(_categoryNameInput(), 'Panel child');
    await tester.tap(find.text(CategoriesKeys.save.en));
    await tester.pumpAndSettle();

    expect(repository.updateCalls, 1);
    expect(repository.createCalls, 1);
    expect(repository.lastCreatedDraft?.parentId, 1);
    expect(
      repository.categories.any((item) => item.name == 'Panel child'),
      isTrue,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('changing filters clears a details selection outside results', (
    tester,
  ) async {
    setScreenSize(tester, const Size(1200, 900));
    _register(
      FakeCategoriesRepository(
        categories: _sampleCategories().take(4).toList(),
      ),
    );
    await tester.pumpWidget(
      buildTestApp(home: _home(), direction: TextDirection.ltr),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Root').first);
    await tester.pumpAndSettle();
    expect(_listCubit(tester).selectedId.value, 1);

    _listCubit(tester).setStatus(CategoryStatusFilter.inactive);
    await tester.pumpAndSettle();

    expect(_listCubit(tester).selectedId.value, isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('parent selector appears before category identity fields', (
    tester,
  ) async {
    setScreenSize(tester, const Size(1200, 900));
    _register(FakeCategoriesRepository(categories: []));
    await tester.pumpWidget(
      buildTestApp(home: _home(), direction: TextDirection.ltr),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text(CategoriesKeys.add.en).first);
    await tester.pumpAndSettle();

    final parent = tester.getTopLeft(find.text(CategoriesKeys.parent.en).first);
    final name = tester.getTopLeft(
      find.text(CategoriesKeys.categoryName.en).first,
    );
    expect(parent.dy, lessThan(name.dy));
    expect(tester.takeException(), isNull);
  });
}
