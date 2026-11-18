import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:accounting_software/app/core/presentation/design_system/theme/app_theme.dart';
import 'package:accounting_software/app/core/presentation/design_system/theme/extensions/app_semantic_colors.dart';
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

  testWidgets('a SnackBar uses the semantic color of its type', (tester) async {
    await _pump(
      tester,
      (context) => MessageViewWidgets.showMessage(
        context,
        message: 'saved',
        type: MessageType.success,
      ),
    );
    await tester.tap(find.text('go'));
    await tester.pump();

    final bar = tester.widget<SnackBar>(find.byType(SnackBar));
    expect(find.text('saved'), findsOneWidget);
    expect(bar.backgroundColor, AppSemanticColors.light.success);
  });

  testWidgets('error uses ColorScheme.error, warning the semantic warning', (
    tester,
  ) async {
    await _pump(
      tester,
      (context) => MessageViewWidgets.showMessage(
        context,
        message: 'bad',
        type: MessageType.error,
      ),
    );
    await tester.tap(find.text('go'));
    await tester.pump();
    expect(
      tester.widget<SnackBar>(find.byType(SnackBar)).backgroundColor,
      AppTheme.light().colorScheme.error,
    );

    await _pump(
      tester,
      (context) => MessageViewWidgets.showMessage(
        context,
        message: 'careful',
        type: MessageType.warning,
      ),
    );
    await tester.tap(find.text('go'));
    await tester.pump();
    expect(
      tester.widget<SnackBar>(find.byType(SnackBar).last).backgroundColor,
      AppSemanticColors.light.warning,
    );
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
