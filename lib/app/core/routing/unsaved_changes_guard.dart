import 'dart:async';

import 'package:flutter/widgets.dart';

typedef UnsavedChangesConfirmation = Future<bool> Function();

class UnsavedChangesGuard extends ChangeNotifier {
  final Map<Object, _UnsavedFormRegistration> _forms = {};
  Future<bool>? _pendingConfirmation;

  void updateForm({
    required Object key,
    required int branchIndex,
    required bool dirty,
    required UnsavedChangesConfirmation confirm,
  }) {
    if (dirty) {
      _forms[key] = _UnsavedFormRegistration(
        key: key,
        branchIndex: branchIndex,
        confirm: confirm,
      );
    } else {
      _forms.remove(key);
    }
    notifyListeners();
  }

  void unregister(Object key) {
    if (_forms.remove(key) != null) notifyListeners();
  }

  Future<bool> confirmBranch(int branchIndex) async {
    // A second navigation request while a dialog is open is rejected.
    if (_pendingConfirmation != null) return false;

    final completer = Completer<bool>();
    _pendingConfirmation = completer.future;
    var allowed = false;
    try {
      final forms = _forms.values
          .where((form) => form.branchIndex == branchIndex)
          .toList(growable: false);
      for (final form in forms) {
        if (!_forms.containsKey(form.key)) continue;
        if (!await form.confirm()) return false;
        _forms.remove(form.key);
      }
      allowed = true;
      return true;
    } finally {
      _pendingConfirmation = null;
      if (!completer.isCompleted) completer.complete(allowed);
      notifyListeners();
    }
  }
}

class _UnsavedFormRegistration {
  const _UnsavedFormRegistration({
    required this.key,
    required this.branchIndex,
    required this.confirm,
  });

  final Object key;
  final int branchIndex;
  final UnsavedChangesConfirmation confirm;
}

class UnsavedChangesGuardScope extends InheritedWidget {
  const UnsavedChangesGuardScope({
    super.key,
    required this.guard,
    required this.activeBranchIndex,
    required super.child,
  });

  final UnsavedChangesGuard guard;
  final int activeBranchIndex;

  static UnsavedChangesGuardScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<UnsavedChangesGuardScope>();

  @override
  bool updateShouldNotify(UnsavedChangesGuardScope oldWidget) =>
      guard != oldWidget.guard ||
      activeBranchIndex != oldWidget.activeBranchIndex;
}
