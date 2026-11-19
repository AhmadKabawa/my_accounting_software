import 'package:accounting_software/app/core/localization/keys/scope_keys.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_scope_selector/scope_selector.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_badge/app_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/localized_app.dart';
import '../../../../helpers/test_key.dart';

const _label = TestKey('test.scope.label');
const _desktop = Size(1280, 800);
const _mobile = Size(360, 800);

const _main = ScopeOption(id: 'main', name: 'Main branch');
const _north = ScopeOption(id: 'north', name: 'North branch', viewOnly: true);
const _south = ScopeOption(id: 'south', name: 'South branch');

/// What the last selector reported.
ScopeOption? _changed;

Future<void> _pump(
  WidgetTester tester, {
  Size size = _desktop,
  List<ScopeOption> options = const [_main, _north, _south],
  String? selectedId = 'main',
  Future<bool> Function(ScopeOption next)? beforeChange,
  TextDirection direction = TextDirection.rtl,
}) {
  _changed = null;
  setScreenSize(tester, size);
  return tester.pumpWidget(
    buildTestApp(
      direction: direction,
      home: Scaffold(
        body: Align(
          alignment: AlignmentDirectional.topStart,
          child: ScopeSelector(
            labelKey: _label,
            options: options,
            selectedId: selectedId,
            onChanged: (option) => _changed = option,
            beforeChange: beforeChange,
          ),
        ),
      ),
    ),
  );
}

void main() {
  setUp(() => useTranslations(const Locale('ar')));

  testWidgets('no options renders nothing', (tester) async {
    await _pump(tester, options: const [], selectedId: null);

    expect(find.byType(Text), findsNothing);
  });

  group('one option', () {
    testWidgets('shows the name only: no menu, no arrow', (tester) async {
      await _pump(tester, options: const [_main]);

      expect(find.text('Main branch'), findsOneWidget);
      expect(find.byType(PopupMenuButton<ScopeOption>), findsNothing);
      expect(find.byIcon(Icons.expand_more), findsNothing);
    });

    testWidgets('tapping it does nothing', (tester) async {
      await _pump(tester, options: const [_main], size: _mobile);

      await tester.tap(find.text('Main branch'));
      await tester.pumpAndSettle();

      expect(find.byType(BottomSheet), findsNothing);
      expect(_changed, isNull);
    });

    testWidgets('a view-only scope shows the badge', (tester) async {
      await _pump(tester, options: const [_north], selectedId: 'north');

      expect(find.text(ScopeKeys.viewOnly.ar), findsOneWidget);
      expect(find.byType(AppBadge), findsOneWidget);
    });
  });

  group('several options on desktop', () {
    testWidgets('opens a menu under the control', (tester) async {
      await _pump(tester);
      expect(find.byIcon(Icons.expand_more), findsOneWidget);

      await tester.tap(find.byType(PopupMenuButton<ScopeOption>));
      await tester.pumpAndSettle();

      expect(find.text('North branch'), findsOneWidget);
      expect(find.text('South branch'), findsOneWidget);
      expect(find.byType(BottomSheet), findsNothing);
    });

    testWidgets('choosing an option reports it', (tester) async {
      await _pump(tester);

      await tester.tap(find.byType(PopupMenuButton<ScopeOption>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('South branch'));
      await tester.pumpAndSettle();

      expect(_changed?.id, 'south');
    });

    testWidgets('the current option is marked and the view-only one badged', (
      tester,
    ) async {
      await _pump(tester);

      await tester.tap(find.byType(PopupMenuButton<ScopeOption>));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check), findsOneWidget);
      expect(find.text(ScopeKeys.viewOnly.ar), findsOneWidget);
    });

    testWidgets('choosing the current option reports nothing', (tester) async {
      await _pump(tester);

      await tester.tap(find.byType(PopupMenuButton<ScopeOption>));
      await tester.pumpAndSettle();
      // The trigger and the menu both show the current name; the menu item is
      // the last one.
      await tester.tap(find.text('Main branch').last);
      await tester.pumpAndSettle();

      expect(_changed, isNull);
    });
  });

  group('several options on mobile', () {
    testWidgets('opens a bottom sheet with a title', (tester) async {
      await _pump(tester, size: _mobile);

      await tester.tap(find.text('Main branch'));
      await tester.pumpAndSettle();

      expect(find.byType(BottomSheet), findsOneWidget);
      expect(find.byType(PopupMenuButton<ScopeOption>), findsNothing);
      expect(find.text('test.scope.label'), findsWidgets);
    });

    testWidgets('choosing an option closes the sheet and reports it', (
      tester,
    ) async {
      await _pump(tester, size: _mobile);

      await tester.tap(find.text('Main branch'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('North branch'));
      await tester.pumpAndSettle();

      expect(find.byType(BottomSheet), findsNothing);
      expect(_changed?.id, 'north');
    });
  });

  group('beforeChange (open cart guard)', () {
    testWidgets('false keeps the current scope', (tester) async {
      var asked = 0;
      await _pump(
        tester,
        size: _mobile,
        beforeChange: (next) async {
          asked++;
          return false;
        },
      );

      await tester.tap(find.text('Main branch'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('South branch'));
      await tester.pumpAndSettle();

      expect(asked, 1);
      expect(_changed, isNull);
    });

    testWidgets('true lets the switch through', (tester) async {
      ScopeOption? asked;
      await _pump(
        tester,
        size: _mobile,
        beforeChange: (next) async {
          asked = next;
          return true;
        },
      );

      await tester.tap(find.text('Main branch'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('South branch'));
      await tester.pumpAndSettle();

      expect(asked?.id, 'south');
      expect(_changed?.id, 'south');
    });

    testWidgets('is not asked when the current option is chosen again', (
      tester,
    ) async {
      var asked = 0;
      await _pump(
        tester,
        size: _mobile,
        beforeChange: (next) async {
          asked++;
          return true;
        },
      );

      await tester.tap(find.text('Main branch'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Main branch').last);
      await tester.pumpAndSettle();

      expect(asked, 0);
      expect(_changed, isNull);
    });
  });

  group('layout', () {
    testWidgets('a long name does not overflow a narrow space', (tester) async {
      const long = ScopeOption(
        id: 'long',
        name: 'A very long branch name that does not fit in the top bar at all',
        viewOnly: true,
      );
      for (final direction in TextDirection.values) {
        await _pump(
          tester,
          size: _mobile,
          options: const [long, _main],
          selectedId: 'long',
          direction: direction,
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull, reason: '$direction');
      }
    });
  });
}
