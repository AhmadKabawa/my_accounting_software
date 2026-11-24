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
import 'package:accounting_software/app/core/foundation/types/paged_query.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/core/localization/keys/catalog_ui_keys.dart';
import 'package:accounting_software/app/core/localization/keys/common_keys.dart';
import 'package:accounting_software/app/core/presentation/state_management/paged_list/paged_list_cubit.dart';
import 'package:accounting_software/app/core/presentation/state_management/paged_list/paged_result.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_table/data_table.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_view/app_data_view.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_view/app_view_mode.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_view/view_mode_switcher.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_page_template/app_page_templates.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/flash_messages.dart';
import 'package:accounting_software/app/core/storage/shared_preferences/app_settings_manager.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_flows_config.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_list_config.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_list_screen.dart';
import '../../../../helpers/localized_app.dart';
import '../../../../helpers/memory_storage.dart';
import '../../../../helpers/test_key.dart';

const _title = TestKey('crud title');
const _search = TestKey('crud search');
const _add = TestKey('crud add');
const _failureKey = TestKey('crud load failure');
const _deletedKey = TestKey('crud deleted');

enum _Effect { changed, ignored }

class _Query implements PagedQuery<_Query> {
  const _Query({this.search = '', this.page = 1, this.pageSize = 10});

  @override
  final String search;
  @override
  final int page;
  @override
  final int pageSize;

  @override
  bool get hasActiveFilters => search.isNotEmpty;

  @override
  _Query withSearch(String value) => _Query(search: value, pageSize: pageSize);

  @override
  _Query withPage(int value) =>
      _Query(search: search, page: value, pageSize: pageSize);

  @override
  _Query cleared() => _Query(pageSize: pageSize);
}

class _TestCubit extends PagedListCubit<String, _Query, _Effect> {
  _TestCubit()
    : super(initialQuery: const _Query(), flashMessages: FlashMessages());

  bool failNextFetch = false;
  int fetchCalls = 0;
  List<String> rows = const ['alpha', 'beta'];

  @override
  Future<Either<Failure, PagedResult<String>>> fetch(_Query query) async {
    fetchCalls++;
    if (failNextFetch) {
      failNextFetch = false;
      return const Left(ServerFailure(messageKey: _failureKey));
    }
    return Right(
      PaginatedResult<String>(
        items: rows,
        totalCount: rows.length,
        currentPage: query.page,
        totalPages: 1,
      ),
    );
  }

  @override
  Future<Either<Failure, Unit>> deleteItem(String item) async =>
      const Right(unit);

  @override
  TestKey get deletedMessageKey => _deletedKey;

  @override
  _Effect buildMutationEffect(PagedMutationKind kind) => _Effect.changed;

  Future<void> mutate() => reloadAfterMutation(PagedMutationKind.updated);

  void sendIgnoredEffect() => emitEffect(_Effect.ignored);
}

class _AccessRepository implements AccessRepository {
  @override
  Future<Either<Failure, AccessSnapshot>> getMyAccess() async => Right(
    AccessSnapshot(
      userId: 'crud-test',
      username: 'crud-test',
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

CrudListConfig<String, _Query, _TestCubit, _Effect> _config({
  required _TestCubit Function() createCubit,
  void Function(BuildContext context)? onAdd,
  void Function(BuildContext context)? onMutated,
  bool Function(_Effect effect)? isMutationEffect,
  CrudFlowsConfig<String, _TestCubit>? flows,
  CrudCapabilities capabilities = const CrudCapabilities(),
  List<Widget> Function(CrudSlotContext<String, _Query, _TestCubit> slot)?
  extraToolbarActions,
  List<Widget> Function(CrudSlotContext<String, _Query, _TestCubit> slot)?
  extraFilterControls,
  List<Widget> Function(CrudSlotContext<String, _Query, _TestCubit> slot)?
  headerExtras,
  Widget Function(CrudSlotContext<String, _Query, _TestCubit> slot)?
  statsBuilder,
  void Function(CrudDataContext<String, _Query, _TestCubit> data)? onData,
}) => CrudListConfig<String, _Query, _TestCubit, _Effect>(
  screenId: 'crud.screen.test',
  titleKey: _title,
  manageAccess: Permissions.masterData.manage,
  searchHintKey: _search,
  addLabelKey: _add,
  onAdd: onAdd,
  createCubit: createCubit,
  rowId: (row) => row,
  itemLabel: (row) => row,
  sort: CrudSortConfig<_Query, _TestCubit>(
    current: (_) => const [],
    tableKey: (_) => null,
    tableAscending: (_) => true,
    apply: (_, _) {},
    applyTable: (_, _) {},
  ),
  filterControls: (_) => const [],
  activeFilters: (_) => const [],
  breadcrumb: (_) => const SizedBox.shrink(),
  capabilities: capabilities,
  onMutated: onMutated,
  isMutationEffect: isMutationEffect,
  flows: flows,
  extraToolbarActions: extraToolbarActions,
  extraFilterControls: extraFilterControls,
  headerExtras: headerExtras,
  statsBuilder: statsBuilder,
  dataSection: (data) {
    onData?.call(data);
    return AppDataView<String>(
      columns: const [
        DataTableColumn<String>(
          labelKey: _title,
          cellBuilder: (_, row) => Text(row),
        ),
      ],
      rows: data.rows,
      rowId: data.rowId,
      mode: data.mode,
      loading: data.loading,
      refreshing: data.refreshing,
      errorKey: data.failure?.messageKey,
      onRetry: data.onRetry,
      selectedIds: data.selectedIds,
      onSelectionChanged: data.onSelectionChanged,
      cardBuilder: (_, row) => Text(row),
      gridItemBuilder: (_, row) => Text(row),
      page: data.query.page,
      pageSize: data.query.pageSize,
      totalCount: data.total,
      hasMore: data.query.page * data.query.pageSize < data.total,
      onPageChanged: data.onPageChanged,
    );
  },
);

Future<_TestCubit> _pump(
  WidgetTester tester, {
  required CrudListConfig<String, _Query, _TestCubit, _Effect> config,
  Size size = const Size(900, 760),
  TextDirection direction = TextDirection.rtl,
  double textScale = 1,
}) async {
  setScreenSize(tester, size);
  sl.registerSingleton<AppSettingsManager>(
    AppSettingsManager(storage: MemoryStorage()),
  );
  await tester.pumpWidget(
    buildTestApp(
      direction: direction,
      textScale: textScale,
      home: BlocProvider<AccessCubit>(
        create: (_) =>
            AccessCubit(getMyAccess: GetMyAccessUseCase(_AccessRepository()))
              ..load(),
        child: CrudListScreen<String, _Query, _TestCubit, _Effect>(
          config: config,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return BlocProvider.of<_TestCubit>(
    tester.element(find.byType(ListPageTemplate)),
  );
}

void main() {
  setUpAll(() => useTranslations(const Locale('en')));
  tearDown(() async => sl.reset());

  testWidgets('loads content and preserves rows after a refresh failure', (
    tester,
  ) async {
    late _TestCubit cubit;
    cubit = await _pump(
      tester,
      config: _config(createCubit: () => _TestCubit()),
    );
    expect(find.text('alpha'), findsOneWidget);
    cubit
      ..failNextFetch = true
      ..refresh();
    await tester.pumpAndSettle();
    expect(find.text('alpha'), findsOneWidget);
    expect(find.text(_failureKey.en), findsOneWidget);
  });

  testWidgets('initial error can be retried into content', (tester) async {
    late _TestCubit cubit;
    cubit = await _pump(
      tester,
      config: _config(createCubit: () => _TestCubit()..failNextFetch = true),
    );
    expect(find.text(_failureKey.en), findsOneWidget);
    await tester.tap(find.text(CommonKeys.retry.en));
    await tester.pumpAndSettle();
    expect(find.text('alpha'), findsOneWidget);
    expect(cubit.fetchCalls, 2);
  });

  testWidgets('mutation callback runs only for matching effects', (
    tester,
  ) async {
    var mutationCount = 0;
    final cubit = await _pump(
      tester,
      config: _config(
        createCubit: _TestCubit.new,
        onMutated: (_) => mutationCount++,
        isMutationEffect: (effect) => effect == _Effect.changed,
      ),
    );
    await cubit.mutate();
    await tester.pumpAndSettle();
    expect(mutationCount, 1);
    cubit.sendIgnoredEffect();
    await tester.pumpAndSettle();
    expect(mutationCount, 1);
  });

  testWidgets('optional slots are empty by default and render independently', (
    tester,
  ) async {
    await _pump(tester, config: _config(createCubit: _TestCubit.new));
    expect(find.byKey(const ValueKey('toolbar-extra')), findsNothing);
    expect(find.byKey(const ValueKey('header-extra')), findsNothing);
    expect(find.byKey(const ValueKey('stats-extra')), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    var filterSlotCalls = 0;
    await _pump(
      tester,
      config: _config(
        createCubit: _TestCubit.new,
        extraToolbarActions: (_) => [
          const Text('toolbar', key: ValueKey('toolbar-extra')),
        ],
        extraFilterControls: (_) {
          filterSlotCalls++;
          return const [SizedBox.shrink()];
        },
        headerExtras: (_) => [
          const Text('header', key: ValueKey('header-extra')),
        ],
        statsBuilder: (_) => const Text('stats', key: ValueKey('stats-extra')),
      ),
    );
    expect(find.byKey(const ValueKey('toolbar-extra')), findsOneWidget);
    expect(find.byKey(const ValueKey('header-extra')), findsOneWidget);
    expect(find.byKey(const ValueKey('stats-extra')), findsOneWidget);
    expect(filterSlotCalls, greaterThan(0));
  });

  testWidgets('add flow receives the provider context and saved callback', (
    tester,
  ) async {
    late _TestCubit cubit;
    var contextCanReadCubit = false;
    var savedCount = 0;
    final flows = CrudFlowsConfig<String, _TestCubit>(
      showEditor: (context, {item, duplicate = false}) async {
        contextCanReadCubit = identical(context.read<_TestCubit>(), cubit);
        return true;
      },
      onSaved: (current, {required isNew}) async {
        expect(identical(current, cubit), isTrue);
        savedCount++;
      },
      itemLabel: (item) => item,
      delete: (current, item) => current.delete(item),
      activate: (_, _) async {},
      deactivate: (_, _) async => const Right(unit),
      deleteTitleKey: _title,
      deleteMessageKey: _title,
      deactivateTitleKey: _title,
      deactivateMessageKey: _title,
      editLabelKey: _title,
      deleteLabelKey: _title,
      duplicateLabelKey: _title,
      activateLabelKey: _title,
      deactivateLabelKey: _title,
      isActive: (_) => false,
    );
    cubit = await _pump(
      tester,
      config: _config(createCubit: _TestCubit.new, flows: flows),
    );
    await tester.tap(find.text(_add.en));
    await tester.pumpAndSettle();
    expect(contextCanReadCubit, isTrue);
    expect(savedCount, 1);
  });

  testWidgets('duplicate capability and count are configurable', (
    tester,
  ) async {
    late CrudDataContext<String, _Query, _TestCubit> data;
    await _pump(
      tester,
      config: _config(
        createCubit: _TestCubit.new,
        capabilities: const CrudCapabilities(duplicate: false, showCount: true),
        onData: (value) => data = value,
      ),
    );
    expect(data.actions.onDuplicate, isNull);
    expect(
      tester.widget<ListPageTemplate>(find.byType(ListPageTemplate)).count,
      2,
    );
  });

  testWidgets('view changes clear selection in narrow RTL at larger text', (
    tester,
  ) async {
    final cubit = await _pump(
      tester,
      size: const Size(280, 760),
      direction: TextDirection.rtl,
      textScale: 1.5,
      config: _config(createCubit: _TestCubit.new),
    );
    cubit.selection.replace({'alpha'});
    cubit.setSelectionMode(true);
    await tester.pumpAndSettle();
    expect(cubit.selection.state, {'alpha'});
    final switcher = find.byType(ViewModeSwitcher);
    expect(switcher, findsOneWidget);
    await tester.tap(
      find.descendant(of: switcher, matching: find.byType(InkWell)).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(CatalogUiKeys.viewCards.en));
    await tester.pumpAndSettle();
    expect(cubit.selection.state, isEmpty);
    expect(tester.takeException(), isNull);
  });
}
