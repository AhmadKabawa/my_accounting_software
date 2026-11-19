import 'package:flutter/widgets.dart';

typedef UnsavedChangesConfirmation = Future<bool> Function();
typedef UnsavedChangesDiscard = void Function();

class UnsavedChangesGuard extends ChangeNotifier {
  final Map<Object, _UnsavedFormRegistration> _forms = {};
  bool _confirming = false;

  /// Updates a form registration and synchronously notifies listeners.
  ///
  /// When called from a widget lifecycle hook during the build frame,
  /// listeners are invoked in that same frame.
  void updateForm({
    required Object key,
    required int branchIndex,
    required bool dirty,
    required UnsavedChangesConfirmation confirm,
    required UnsavedChangesDiscard discard,
  }) {
    if (dirty) {
      _forms[key] = _UnsavedFormRegistration(
        key: key,
        branchIndex: branchIndex,
        confirm: confirm,
        discard: discard,
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
    if (_confirming) return false;
    _confirming = true;
    try {
      final forms = _forms.values
          .where((form) => form.branchIndex == branchIndex)
          .toList(growable: false);
      for (final form in forms) {
        if (!_forms.containsKey(form.key)) continue;
        if (!await form.confirm()) return false;
      }
      return true;
    } finally {
      _confirming = false;
    }
  }

  /// Confirms every registered dirty form, regardless of its branch.
  ///
  /// A snapshot prevents registrations added during a dialog from joining the
  /// current confirmation pass. Registrations removed while awaiting a dialog
  /// are skipped.
  Future<bool> confirmAll() async {
    if (_confirming) return false;
    _confirming = true;
    try {
      final forms = _forms.values.toList(growable: false);
      for (final form in forms) {
        if (!identical(_forms[form.key], form)) continue;
        if (!await form.confirm()) return false;
      }
      return true;
    } finally {
      _confirming = false;
    }
  }

  /// Discards every currently registered dirty form after a successful
  /// global transition (for example logout or changing the organization).
  void discardAll() {
    final forms = _forms.values.toList(growable: false);
    for (final form in forms) {
      if (identical(_forms[form.key], form)) form.discard();
    }
  }

  /// Discards forms only after the owner has committed the guarded transition.
  void discardBranch(int branchIndex) {
    final forms = _forms.values
        .where((form) => form.branchIndex == branchIndex)
        .toList(growable: false);
    for (final form in forms) {
      if (_forms.containsKey(form.key)) form.discard();
    }
  }
}

class _UnsavedFormRegistration {
  const _UnsavedFormRegistration({
    required this.key,
    required this.branchIndex,
    required this.confirm,
    required this.discard,
  });

  final Object key;
  final int branchIndex;
  final UnsavedChangesConfirmation confirm;
  final UnsavedChangesDiscard discard;
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
