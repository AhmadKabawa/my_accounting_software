import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/presentation/design_system/theme/app_theme.dart';
import 'package:accounting_software/app/core/presentation/design_system/theme/extensions/app_semantic_colors.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/message_view_widgets.dart';

Future<void> _pump(
  WidgetTester tester,
  void Function(BuildContext context) onTap,
) => tester.pumpWidget(
  MaterialApp(
    theme: AppTheme.light(),
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
}
