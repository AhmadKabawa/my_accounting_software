import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:accounting_software/app/core/presentation/design_system/theme/app_theme.dart';
import 'package:accounting_software/app/core/localization/keys/common_keys.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/design_system/theme/extensions/app_saas_colors.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/message_view_widgets.dart';

import '../../../../helpers/localized_app.dart';

Future<void> _pump(
  WidgetTester tester,
  void Function(BuildContext context) onTap,
) => tester.pumpWidget(
  buildTestApp(
    home: Scaffold(
      body: Builder(
        builder: (context) => TextButton(
          onPressed: () => onTap(context),
          child: const Text('go'),
        ),
      ),
    ),
  ),
);

void main() {
  setUp(() => useTranslations(const Locale('ar')));

  Future<SnackBar> showSnack(
    WidgetTester tester,
    MessageType type, {
    String text = 'msg',
    AppKey? actionKey,
    VoidCallback? onAction,
    ThemeData? theme,
    Size size = const Size(1200, 800),
  }) async {
    setScreenSize(tester, size);
    await tester.pumpWidget(
      buildTestApp(
        theme: theme ?? AppTheme.light(),
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => MessageViewWidgets.showMessage(
                context,
                message: text,
                type: type,
                actionKey: actionKey,
                onAction: onAction,
              ),
              child: const Text('go'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('go'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    return tester.widget<SnackBar>(find.byType(SnackBar));
  }

  group('SnackBar', () {
    testWidgets('quiet pill background per type, never another type\'s', (
      tester,
    ) async {
      const light = AppSaasColors.light;
      final expected = {
        MessageType.success: light.pillSuccess.container,
        MessageType.error: light.pillError.container,
        MessageType.warning: light.pillWarning.container,
        MessageType.info: light.pillInfo.container,
      };
      for (final entry in expected.entries) {
        final bar = await showSnack(tester, entry.key, text: entry.key.name);
        expect(bar.backgroundColor, entry.value, reason: entry.key.name);
        tester
            .state<ScaffoldMessengerState>(find.byType(ScaffoldMessenger))
            .clearSnackBars();
        await tester.pumpAndSettle();
      }
      expect(expected[MessageType.error], isNot(expected[MessageType.success]));
    });

    testWidgets('the semantic icon is actually drawn', (tester) async {
      await showSnack(tester, MessageType.error);
      expect(
        find.descendant(
          of: find.byType(SnackBar),
          matching: find.byType(AppIcon),
        ),
        findsWidgets,
      );
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('has a close button that dismisses it', (tester) async {
      await showSnack(tester, MessageType.info);
      await tester.tap(find.byTooltip('إغلاق'));
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('optional action fires and closes', (tester) async {
      var undone = 0;
      await showSnack(
        tester,
        MessageType.success,
        actionKey: CommonKeys.retry,
        onAction: () => undone++,
      );
      await tester.tap(find.text('إعادة المحاولة'));
      await tester.pumpAndSettle();
      expect(undone, 1);
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('limited width on desktop, full width on a phone', (
      tester,
    ) async {
      final wide = await showSnack(tester, MessageType.info);
      expect(wide.width, isNotNull);
      expect(wide.margin, isNull);
      tester
          .state<ScaffoldMessengerState>(find.byType(ScaffoldMessenger))
          .clearSnackBars();
      await tester.pumpAndSettle();
      final phone = await showSnack(
        tester,
        MessageType.info,
        size: const Size(360, 800),
      );
      expect(phone.width, isNull);
      expect(phone.margin, isNotNull);
    });

    testWidgets('the same message is not shown twice while visible', (
      tester,
    ) async {
      setScreenSize(tester, const Size(1200, 800));
      late BuildContext ctx;
      await tester.pumpWidget(
        buildTestApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                ctx = context;
                return const SizedBox();
              },
            ),
          ),
        ),
      );
      for (var i = 0; i < 3; i++) {
        MessageViewWidgets.showMessage(
          ctx,
          message: 'same',
          type: MessageType.error,
        );
      }
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('same'), findsOneWidget);
      tester
          .state<ScaffoldMessengerState>(find.byType(ScaffoldMessenger))
          .clearSnackBars();
      await tester.pumpAndSettle();
      expect(find.text('same'), findsNothing);
    });

    testWidgets('renders in dark theme and RTL without errors', (tester) async {
      for (final type in [
        MessageType.error,
        MessageType.success,
        MessageType.warning,
        MessageType.info,
      ]) {
        await showSnack(tester, type, theme: AppTheme.dark(), text: type.name);
        expect(tester.takeException(), isNull);
        tester
            .state<ScaffoldMessengerState>(find.byType(ScaffoldMessenger))
            .clearSnackBars();
        await tester.pumpAndSettle();
      }
    });

    testWidgets('long text is capped, not stretched', (tester) async {
      await showSnack(tester, MessageType.warning, text: 'long ' * 200);
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('a dialog shows the message with an AppButton to close it', (
    tester,
  ) async {
    await _pump(
      tester,
      (context) => MessageViewWidgets.showMessage(
        context,
        message: 'hello',
        title: 'Title',
        type: MessageType.info,
        isDialog: true,
      ),
    );
    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('hello'), findsOneWidget);
    expect(find.text('Title'), findsOneWidget);
    expect(find.byType(AppButton), findsOneWidget);
  });

  testWidgets('loading blocks back navigation and hideMessage closes it', (
    tester,
  ) async {
    late BuildContext ctx;
    await _pump(tester, (context) {
      ctx = context;
      MessageViewWidgets.showMessage(
        context,
        message: 'wait',
        type: MessageType.loading,
      );
    });
    await tester.tap(find.text('go'));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(tester.widget<PopScope>(find.byType(PopScope).last).canPop, isFalse);

    MessageViewWidgets.hideMessage(ctx);
    await tester.pumpAndSettle();
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  group('hideMessage never closes a page', () {
    // Page A opens page B; B's context is captured for direct calls.
    late BuildContext pageB;

    Future<void> openPageB(WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => Scaffold(
                      body: Builder(
                        builder: (context) {
                          pageB = context;
                          return const Text('page B');
                        },
                      ),
                    ),
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.text('page B'), findsOneWidget);
    }

    testWidgets('with no message open it does nothing (called twice)', (
      tester,
    ) async {
      await openPageB(tester);

      MessageViewWidgets.hideMessage(pageB);
      MessageViewWidgets.hideMessage(pageB);
      await tester.pumpAndSettle();

      expect(find.text('page B'), findsOneWidget);
    });

    testWidgets('closes the loading message and keeps the page', (
      tester,
    ) async {
      await openPageB(tester);
      MessageViewWidgets.showMessage(
        pageB,
        message: 'wait',
        type: MessageType.loading,
      );
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      MessageViewWidgets.hideMessage(pageB);
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('page B'), findsOneWidget);
    });

    testWidgets('a second call after closing does not pop the page', (
      tester,
    ) async {
      await openPageB(tester);
      MessageViewWidgets.showMessage(
        pageB,
        message: 'wait',
        type: MessageType.loading,
      );
      await tester.pump();

      MessageViewWidgets.hideMessage(pageB);
      MessageViewWidgets.hideMessage(pageB);
      await tester.pumpAndSettle();

      expect(find.text('page B'), findsOneWidget);
    });

    testWidgets('show then hide in the same frame leaves nothing open', (
      tester,
    ) async {
      await openPageB(tester);

      MessageViewWidgets.showMessage(
        pageB,
        message: 'wait',
        type: MessageType.loading,
      );
      MessageViewWidgets.hideMessage(pageB);
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('page B'), findsOneWidget);
    });

    testWidgets('closes an error dialog as well', (tester) async {
      await openPageB(tester);
      MessageViewWidgets.showMessage(
        pageB,
        message: 'bad',
        type: MessageType.error,
        isDialog: true,
      );
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);

      MessageViewWidgets.hideMessage(pageB);
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text('page B'), findsOneWidget);
    });

    testWidgets('does not close a dialog that is not a message', (
      tester,
    ) async {
      await openPageB(tester);
      showDialog<void>(
        context: pageB,
        builder: (_) => const AlertDialog(content: Text('foreign')),
      );
      await tester.pumpAndSettle();

      MessageViewWidgets.hideMessage(pageB);
      await tester.pumpAndSettle();

      expect(find.text('foreign'), findsOneWidget);
    });

    testWidgets('leaves a SnackBar alone', (tester) async {
      await openPageB(tester);
      MessageViewWidgets.showMessage(pageB, message: 'saved');
      await tester.pump();
      await tester.pump();

      MessageViewWidgets.hideMessage(pageB);
      await tester.pumpAndSettle(const Duration(milliseconds: 100));

      expect(find.text('page B'), findsOneWidget);
      expect(find.text('saved'), findsOneWidget);
    });

    testWidgets('works from inside a ShellRoute (nested navigator)', (
      tester,
    ) async {
      late BuildContext inShell;
      final router = GoRouter(
        initialLocation: '/a',
        routes: [
          ShellRoute(
            builder: (context, state, child) => Scaffold(body: child),
            routes: [
              GoRoute(
                path: '/a',
                builder: (context, state) => Builder(
                  builder: (context) {
                    inShell = context;
                    return const Text('page A');
                  },
                ),
              ),
            ],
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(buildTestApp(router: router));
      await tester.pumpAndSettle();

      MessageViewWidgets.showMessage(
        inShell,
        message: 'wait',
        type: MessageType.loading,
      );
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      MessageViewWidgets.hideMessage(inShell);
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('page A'), findsOneWidget);
    });
  });

  group('message types', () {
    for (final type in [
      MessageType.success,
      MessageType.error,
      MessageType.warning,
      MessageType.info,
    ]) {
      testWidgets('${type.name} dialog shows its text and an icon', (
        tester,
      ) async {
        await _pump(
          tester,
          (context) => MessageViewWidgets.showMessage(
            context,
            message: 'text',
            title: 'head',
            type: type,
            isDialog: true,
          ),
        );
        await tester.tap(find.text('go'));
        await tester.pumpAndSettle();

        expect(find.text('text'), findsOneWidget);
        expect(find.text('head'), findsOneWidget);
        expect(find.byType(Icon), findsOneWidget);
      });
    }
  });
}
