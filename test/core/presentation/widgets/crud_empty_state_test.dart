import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/access/cubit/access_cubit.dart';
import 'package:accounting_software/app/core/access/models/access_snapshot.dart';
import 'package:accounting_software/app/core/access/permission.dart';
import 'package:accounting_software/app/core/presentation/design_system/theme/app_theme.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_empty_state/crud_empty_state.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_page_template/list_add_action.dart';
import '../../../helpers/localized_app.dart';
import '../../../helpers/test_key.dart';

class _MockAccessCubit extends MockCubit<AccessState>
    implements AccessCubit {}

void main() {
  setUpAll(() => useTranslations(const Locale('en')));

  const emptyTitle = TestKey('empty.title');
  const emptyDescription = TestKey('empty.description');
  const noResultsTitle = TestKey('no_results.title');
  const noResultsDescription = TestKey('no_results.description');
  const addLabel = TestKey('add.label');

  final readyState = AccessState(
    status: AccessStatus.ready,
    snapshot: const AccessSnapshot(
      userId: 'user',
      username: 'User',
      email: null,
      isSuperAdmin: false,
      roles: [],
      permissions: {Permission('masterdata.manage')},
      branches: [],
      warehouses: [],
      posTerminals: [],
    ),
  );

  Future<void> pumpState(
    WidgetTester tester, {
    required bool hasActiveFilters,
    ListAddAction? addAction,
    AccessState? accessState,
  }) async {
    final cubit = _MockAccessCubit();
    whenListen(
      cubit,
      const Stream<AccessState>.empty(),
      initialState: accessState ?? readyState,
    );
    await tester.pumpWidget(
      buildTestApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: BlocProvider<AccessCubit>.value(
            value: cubit,
            child: CrudEmptyState(
              icon: AppIcons.info,
              emptyTitleKey: emptyTitle,
              emptyDescriptionKey: emptyDescription,
              noResultsTitleKey: noResultsTitle,
              noResultsDescriptionKey: noResultsDescription,
              hasActiveFilters: hasActiveFilters,
              addAction: addAction,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('empty state shows create action when supplied', (tester) async {
    var added = false;
    await pumpState(
      tester,
      hasActiveFilters: false,
      addAction: ListAddAction(
        labelKey: addLabel,
        permission: const Permission('masterdata.manage'),
        onPressed: () => added = true,
      ),
    );

    expect(find.text(emptyTitle.en), findsOneWidget);
    expect(find.text(emptyDescription.en), findsOneWidget);
    expect(find.byType(AppButton), findsOneWidget);
    await tester.tap(find.byType(AppButton));
    expect(added, isTrue);
  });

  testWidgets('active filters show no-results copy without create action', (
    tester,
  ) async {
    await pumpState(
      tester,
      hasActiveFilters: true,
      addAction: ListAddAction(
        labelKey: addLabel,
        permission: const Permission('masterdata.manage'),
        onPressed: () {},
      ),
    );

    expect(find.text(noResultsTitle.en), findsOneWidget);
    expect(find.text(noResultsDescription.en), findsOneWidget);
    expect(find.byType(AppButton), findsNothing);
  });

  testWidgets('empty state omits create action when none is supplied', (
    tester,
  ) async {
    await pumpState(tester, hasActiveFilters: false);
    expect(find.text(emptyTitle.en), findsOneWidget);
    expect(find.byType(AppButton), findsNothing);
  });

  testWidgets('permission gate hides create action without permission', (
    tester,
  ) async {
    await pumpState(
      tester,
      hasActiveFilters: false,
      accessState: const AccessState(),
      addAction: ListAddAction(
        labelKey: addLabel,
        permission: const Permission('masterdata.manage'),
        onPressed: () {},
      ),
    );
    expect(find.byType(AppButton), findsNothing);
  });
}
