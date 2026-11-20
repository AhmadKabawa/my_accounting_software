import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/routing/app_go_router.dart';
import 'package:accounting_software/app/shell/app_shell.dart';

void main() {
  test('router sign-out entry does not discard forms when sign-out fails', () async {
    var discarded = false;
    final entry = buildSignOutMenuEntry(signOut: () async => false);

    final succeeded = await runGuardedUserMenuAction(
      entry: entry,
      confirmAllForms: () async => true,
      isMounted: () => true,
      discardAll: () => discarded = true,
    );

    expect(succeeded, isFalse);
    expect(discarded, isFalse);
  });

  test('guard rejection does not invoke the menu action or discard forms', () async {
    var actionCalled = false;
    var discarded = false;
    final entry = buildSignOutMenuEntry(signOut: () async {
      actionCalled = true;
      return true;
    });

    final succeeded = await runGuardedUserMenuAction(
      entry: entry,
      confirmAllForms: () async => false,
      isMounted: () => true,
      discardAll: () => discarded = true,
    );

    expect(succeeded, isFalse);
    expect(actionCalled, isFalse);
    expect(discarded, isFalse);
  });

  test('forms are discarded only after guarded action succeeds', () async {
    var discarded = false;
    final entry = buildSignOutMenuEntry(signOut: () async => true);

    final succeeded = await runGuardedUserMenuAction(
      entry: entry,
      confirmAllForms: () async => true,
      isMounted: () => true,
      discardAll: () => discarded = true,
    );

    expect(succeeded, isTrue);
    expect(discarded, isTrue);
  });
}
