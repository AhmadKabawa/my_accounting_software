import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/access/cubit/access_cubit.dart';
import 'package:accounting_software/app/core/access/domain/access_repository.dart';
import 'package:accounting_software/app/core/access/domain/get_my_access_usecase.dart';
import 'package:accounting_software/app/core/access/models/access_snapshot.dart';
import 'package:accounting_software/app/core/access/permissions.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/types/paged_query.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_table/data_table.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_view/app_view_mode.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_row_actions/app_row_actions.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_switch/app_switch.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_page_template/list_add_action.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_data_section.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_flows_config.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_labels.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_list_config.dart';
import '../../../../helpers/localized_app.dart';
import '../../../../helpers/test_key.dart';

const _label = TestKey('data section label');
const _empty = TestKey('empty records');
const _emptyDescription = TestKey('empty description');
const _noResults = TestKey('no results');
const _noResultsDescription = TestKey('no results description');
const _extraAction = TestKey('extra row action');
const _edit = TestKey('row edit');
const _delete = TestKey('row delete');
const _duplicate = TestKey('row duplicate');
const _activate = TestKey('row activate');
const _deactivate = TestKey('row deactivate');
const _confirmTitle = TestKey('confirm title');
const _confirmMessage = TestKey('confirm message');

const _fullLabels = CrudLabels(
  edit: _edit,
  delete: _delete,
  duplicate: _duplicate,
  activate: _activate,
  deactivate: _deactivate,
  deleteConfirmationTitle: _confirmTitle,
  deleteConfirmationMessage: _confirmMessage,
  deactivateConfirmationTitle: _confirmTitle,
  deactivateConfirmationMessage: _confirmMessage,
);
const _noStatusLabels = CrudLabels(
  edit: _edit,
  delete: _delete,
  duplicate: _duplicate,
  deleteConfirmationTitle: _confirmTitle,
  deleteConfirmationMessage: _confirmMessage,
);
const _editOnlyLabels = CrudLabels(edit: _edit);

class _Query implements PagedQuery<_Query> {
  const _Query({this.search = ''});
  @override
  final String search;
  @override
  int get page => 1;
  @override
  int get pageSize => 10;
  @override
  bool get hasActiveFilters => search.isNotEmpty;
  @override
  _Query withSearch(String value) => _Query(search: value);
  @override
  _Query withPage(int value) => this;
  @override
  _Query cleared() => const _Query();
}

class _Row {
  const _Row(this.id);
  final String id;
}

CrudFlowsConfig<_Row, Object> _flows(
  CrudLabels labels, {
  bool withStatus = true,
  bool withDelete = true,
}) => CrudFlowsConfig<_Row, Object>(
  showEditor: (_, {item, duplicate = false}) async => false,
  onSaved: (_, {required isNew}) async {},
  itemLabel: (row) => row.id,
  labels: labels,
  delete: withDelete ? (_, _) async => const Right(unit) : null,
  activate: withStatus ? (_, _) async => const Right(unit) : null,
  deactivate: withStatus ? (_, _) async => const Right(unit) : null,
  isActive: withStatus ? (_) => true : null,
);

CrudDataSection<_Row, _Query, Object> _section({
  AppViewMode? mode = AppViewMode.table,
  List<_Row> rows = const [_Row('one')],
  _Query query = const _Query(),
  Set<Object> busyIds = const {},
  List<AppRowAction> Function(BuildContext context, _Row row)? extraRowActions,
  CrudLabels labels = _fullLabels,
  bool withStatus = true,
  CrudFlowsConfig<_Row, Object>? flows,
}) {
  final data = CrudDataContext<_Row, _Query, Object>(
    mode: mode,
    rows: rows,
    total: rows.length,
    query: query,
    sortKey: 'name',
    sortAscending: true,
    onSort: (_) {},
    permission: Permissions.masterData.manage,
    loading: false,
    refreshing: false,
    failure: null,
    busyIds: busyIds,
    selectedIds: const {},
    onSelectionChanged: (_) {},
    onRetry: () {},
    onPageChanged: (_) {},
    addAction: ListAddAction(
      labelKey: _label,
      permission: Permissions.masterData.manage,
      onPressed: () {},
    ),
    cubit: Object(),
    rowId: (row) => row.id,
    itemLabel: (row) => row.id,
    flows: flows,
  );
  return CrudDataSection<_Row, _Query, Object>(
    data: data,
    columns: [
      DataTableColumn<_Row>(
        labelKey: _label,
        cellBuilder: (_, row) => Text(row.id),
      ),
    ],
    labels: labels,
    statusColumn: withStatus
        ? CrudStatusColumnConfig<_Row>(
            labelKey: _label,
            isActive: (_) => true,
            badgeBuilder: (_, _) => const Text('active'),
            sortKey: 'status',
          )
        : null,
    cardBuilder: (_, row) => Text('card ${row.id}'),
    gridBuilder: (_, row) => Text('grid ${row.id}'),
    icon: AppIcons.brands,
    emptyTitleKey: _empty,
    emptyDescriptionKey: _emptyDescription,
    noResultsTitleKey: _noResults,
    noResultsDescriptionKey: _noResultsDescription,
    extraRowActions: extraRowActions == null
        ? null
        : (context, row) => extraRowActions(context, row),
  );
}

class _AccessRepository implements AccessRepository {
  @override
  Future<Either<Failure, AccessSnapshot>> getMyAccess() async => Right(
    AccessSnapshot(
      userId: 'crud-data-test',
      username: 'crud-data-test',
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

Widget _app(
  Widget child, {
  TextDirection direction = TextDirection.rtl,
  double textScale = 1,
}) => buildTestApp(
  direction: direction,
  textScale: textScale,
  home: BlocProvider<AccessCubit>(
    create: (_) =>
        AccessCubit(getMyAccess: GetMyAccessUseCase(_AccessRepository()))
          ..load(),
    child: Scaffold(body: child),
  ),
);

void main() {
  setUpAll(() => useTranslations(const Locale('en')));

  testWidgets('renders table, cards and grid modes', (tester) async {
    for (final mode in AppViewMode.values) {
      await tester.pumpWidget(_app(_section(mode: mode)));
      await tester.pumpAndSettle();
      if (mode == AppViewMode.table) {
        expect(find.text('one'), findsOneWidget);
      }
      if (mode == AppViewMode.cards) {
        expect(find.text('card one'), findsOneWidget);
      }
      if (mode == AppViewMode.grid) {
        expect(find.text('grid one'), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('projects busy status and extra row overflow actions', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        _section(
          busyIds: {'one'},
          extraRowActions: (_, _) => [
            AppRowAction(
              icon: AppIcons.add,
              labelKey: _extraAction,
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
    // The busy switch intentionally animates; settle would wait forever.
    await tester.pump(const Duration(milliseconds: 100));
    expect(
      tester.widget<AppSwitch>(find.byType(AppSwitch).first).loading,
      isTrue,
    );
    final rowActions = tester.widget<AppRowActions>(
      find.byType(AppRowActions).first,
    );
    expect(
      rowActions.primary.map((action) => action.labelKey),
      contains(_edit),
    );
    expect(
      rowActions.overflow.map((action) => action.labelKey),
      contains(_extraAction),
    );
    expect(
      rowActions.overflow.map((action) => action.labelKey),
      contains(_delete),
    );
  });

  testWidgets('a status entity offers activation, duplicate and delete', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(_section(flows: _flows(_fullLabels), busyIds: const {})),
    );
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(AppSwitch), findsOneWidget);
    final rowActions = tester.widget<AppRowActions>(
      find.byType(AppRowActions).first,
    );
    expect(rowActions.overflow.map((action) => action.labelKey), [
      _deactivate,
      _duplicate,
      _delete,
    ]);
  });

  testWidgets('an entity without status has no status column or action', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        _section(
          labels: _noStatusLabels,
          withStatus: false,
          flows: _flows(_noStatusLabels, withStatus: false),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(AppSwitch), findsNothing);
    final rowActions = tester.widget<AppRowActions>(
      find.byType(AppRowActions).first,
    );
    expect(rowActions.overflow.map((action) => action.labelKey), [
      _duplicate,
      _delete,
    ]);
  });

  testWidgets('duplicate and delete are optional, edit stays', (tester) async {
    await tester.pumpWidget(
      _app(
        _section(
          labels: _editOnlyLabels,
          withStatus: false,
          flows: _flows(_editOnlyLabels, withStatus: false, withDelete: false),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final rowActions = tester.widget<AppRowActions>(
      find.byType(AppRowActions).first,
    );
    expect(rowActions.primary.map((action) => action.labelKey), [_edit]);
    expect(rowActions.overflow, isEmpty);
  });

  testWidgets('empty state distinguishes filters from a new list', (
    tester,
  ) async {
    await tester.pumpWidget(_app(_section(rows: const [])));
    await tester.pumpAndSettle();
    expect(find.text(_empty.en), findsOneWidget);
    await tester.pumpWidget(
      _app(
        _section(
          rows: const [],
          query: const _Query(search: 'x'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text(_noResults.en), findsOneWidget);
  });

  testWidgets('supports narrow RTL and enlarged text without overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(280, 760);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      _app(
        _section(mode: AppViewMode.cards),
        direction: TextDirection.rtl,
        textScale: 1.5,
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
