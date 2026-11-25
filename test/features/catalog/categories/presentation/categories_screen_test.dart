import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/access/cubit/access_cubit.dart';
import 'package:accounting_software/app/core/access/domain/access_repository.dart';
import 'package:accounting_software/app/core/access/domain/get_my_access_usecase.dart';
import 'package:accounting_software/app/core/access/models/access_snapshot.dart';
import 'package:accounting_software/app/core/access/permissions.dart';
import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/localization/keys/catalog_ui_keys.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_page_template/app_page_templates.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text_field/app_text_field.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/flash_messages.dart';
import 'package:accounting_software/app/core/storage/shared_preferences/app_settings_manager.dart';
import 'package:accounting_software/app/features/catalog/categories/di/categories_di.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/entity/category.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/entity/category_list_query.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/usecase/create_category_use_case.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/usecase/delete_category_use_case.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/usecase/get_categories_use_case.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/usecase/set_category_active_use_case.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/usecase/update_category_use_case.dart';
import 'package:accounting_software/app/features/catalog/categories/presentation/cubit/categories_list/categories_list_cubit.dart';
import 'package:accounting_software/app/features/catalog/categories/presentation/cubit/category_form/category_form_cubit.dart';
import 'package:accounting_software/app/features/catalog/categories/presentation/localization/categories_keys.dart';
import 'package:accounting_software/app/features/catalog/categories/presentation/categories_list_page.dart';
import '../../../../helpers/localized_app.dart';
import '../../../../helpers/memory_storage.dart';
import '../support/fake_categories_repository.dart';

class _AccessRepository implements AccessRepository {
  @override
  Future<Either<Failure, AccessSnapshot>> getMyAccess() async => Right(
    AccessSnapshot(
      userId: 'categories-screen-test',
      username: 'categories-screen-test',
      email: null,
      isSuperAdmin: false,
      roles: const [],
      permissions: {Permissions.masterData.manage},
      branches: const [],
      warehouses: const [],
      posTerminals: const [],
    ),
  );
}

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

void _register(FakeCategoriesRepository repository) {
  sl.registerFactory<AppSettingsManager>(
    () => AppSettingsManager(storage: MemoryStorage()),
  );
  sl.registerFactory<FlashMessages>(FlashMessages.new);
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
      tree: args.tree,
      initialParentId: args.initialParentId,
    ),
  );
}

Widget _home() => BlocProvider<AccessCubit>(
  create: (_) =>
      AccessCubit(getMyAccess: GetMyAccessUseCase(_AccessRepository()))..load(),
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

    await tester.tap(find.byTooltip(CatalogUiKeys.moreActions.en).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text(CategoriesKeys.addChild.en));
    await tester.pumpAndSettle();

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(1), 'New child');
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
    setScreenSize(tester, const Size(1200, 900));
    await tester.pumpWidget(
      buildTestApp(home: _home(), direction: TextDirection.ltr),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'initial page');
    _listCubit(tester).expandAll();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'after expanding the tree');

    await tester.tap(find.byTooltip(CatalogUiKeys.moreActions.en).at(2));
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
}
