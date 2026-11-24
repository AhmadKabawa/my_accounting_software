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
import 'package:accounting_software/app/core/presentation/widgets/app_page_template/list_add_action.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_data_section.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_list_config.dart';
import '../../../../helpers/localized_app.dart';
import '../../../../helpers/test_key.dart';

const _label = TestKey('data section label');
const _empty = TestKey('empty records');
const _emptyDescription = TestKey('empty description');
const _noResults = TestKey('no results');
const _noResultsDescription = TestKey('no results description');

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

CrudDataSection<_Row, _Query, Object> _section({
  AppViewMode? mode = AppViewMode.table,
  List<_Row> rows = const [_Row('one')],
  _Query query = const _Query(),
  Set<Object> busyIds = const {},
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
  );
  return CrudDataSection<_Row, _Query, Object>(
    data: data,
    columns: [
      DataTableColumn<_Row>(
        labelKey: _label,
        cellBuilder: (_, row) => Text(row.id),
      ),
    ],
    statusColumn: CrudStatusColumnConfig<_Row>(
      labelKey: _label,
      isActive: (_) => true,
      badgeBuilder: (_, _) => const Text('active'),
      activateLabelKey: _label,
      deactivateLabelKey: _label,
      sortKey: 'status',
    ),
    cardBuilder: (_, row) => Text('card ${row.id}'),
    gridBuilder: (_, row) => Text('grid ${row.id}'),
    icon: AppIcons.brands,
    emptyTitleKey: _empty,
    emptyDescriptionKey: _emptyDescription,
    noResultsTitleKey: _noResults,
    noResultsDescriptionKey: _noResultsDescription,
    editLabelKey: _label,
    deleteLabelKey: _label,
    duplicateLabelKey: _label,
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
      await tester.pumpWidget(
        _app(_section(mode: mode)),
      );
      await tester.pumpAndSettle();
      expect(find.text('one'), findsWidgets);
      if (mode == AppViewMode.cards) {
        expect(find.text('card one'), findsOneWidget);
      }
      if (mode == AppViewMode.grid) {
        expect(find.text('grid one'), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('empty state distinguishes filters from a new list', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(_section(rows: const [])),
    );
    await tester.pumpAndSettle();
    expect(find.text(_empty.en), findsOneWidget);
    await tester.pumpWidget(
      _app(_section(rows: const [], query: const _Query(search: 'x'))),
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
