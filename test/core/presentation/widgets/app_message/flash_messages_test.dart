import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/localization/keys/error_keys.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/flash_messages.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/message_view_widgets.dart';

import '../../../../helpers/localized_app.dart';

Widget _app(FlashMessages flash) => buildTestApp(
  home: Scaffold(
    body: FlashMessageListener(messages: flash, child: const SizedBox()),
  ),
);

void main() {
  setUp(() => useTranslations(const Locale('ar')));

  testWidgets('a message posted while mounted shows as a SnackBar', (
    tester,
  ) async {
    final flash = FlashMessages();
    await tester.pumpWidget(_app(flash));

    flash.post(ErrorKeys.unexpected, MessageType.error);
    await tester.pump();
    await tester.pump();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text(ErrorKeys.unexpected.ar), findsOneWidget);
  });

  testWidgets('a message posted before the listener is shown once mounted', (
    tester,
  ) async {
    final flash = FlashMessages()..post(ErrorKeys.unexpected, MessageType.info);
    expect(flash.pendingCount, 1);

    await tester.pumpWidget(_app(flash));
    await tester.pump();
    await tester.pump();

    expect(find.text(ErrorKeys.unexpected.ar), findsOneWidget);
    expect(flash.pendingCount, 0);
  });

  testWidgets('with no listener the message waits', (tester) async {
    final flash = FlashMessages();
    await tester.pumpWidget(_app(flash));
    await tester.pumpWidget(buildTestApp(home: const SizedBox()));

    flash.post(ErrorKeys.unexpected, MessageType.error);
    await tester.pump();

    expect(flash.pendingCount, 1);
    expect(find.byType(SnackBar), findsNothing);
  });
}
