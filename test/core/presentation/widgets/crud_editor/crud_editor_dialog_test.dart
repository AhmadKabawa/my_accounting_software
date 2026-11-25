import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/localization/keys/common_keys.dart';
import 'package:accounting_software/app/core/localization/keys/template_keys.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/state_management/base_cubit.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_form_dialog/app_form_dialog.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_editor/crud_editor.dart';
import '../../../../helpers/localized_app.dart';
import '../../../../helpers/test_key.dart';

const _add = TestKey('test.crudEditor.add');
const _edit = TestKey('test.crudEditor.edit');
const _duplicate = TestKey('test.crudEditor.duplicate');
const _subtitle = TestKey('test.crudEditor.subtitle');
const _save = TestKey('test.crudEditor.save');
const _cancel = TestKey('test.crudEditor.cancel');
const _failure = CommonKeys.unknownError;

enum _Status { idle, saving }

sealed class _Effect {
  const _Effect();
}

final class _Saved extends _Effect {
  const _Saved();
}

final class _Failed extends _Effect {
  const _Failed();
}

class _EditorCubit extends BaseCubit<_Status, _Effect> {
  _EditorCubit() : super(_Status.idle);
  void succeed() => emitEffect(const _Saved());
  void fail() => emitEffect(const _Failed());
  void setBusy() => emit(_Status.saving);
}

const _labels = CrudEditorLabels(
  addTitle: _add,
  editTitle: _edit,
  duplicateTitle: _duplicate,
  subtitle: _subtitle,
  save: _save,
  cancel: _cancel,
);

Future<void> _open(
  WidgetTester tester, {
  required _EditorCubit cubit,
  required CrudEditorFields fields,
  bool extraBusy = false,
  bool extraDirty = false,
  ValueChanged<bool?>? onResult,
}) async {
  await tester.pumpWidget(
    buildTestApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              final result = await showAppFormDialog<bool>(
                context,
                (_) => CrudEditorDialog<_EditorCubit, _Status, _Effect>(
                  cubit: cubit,
                  fields: fields,
                  mode: CrudEditorMode.add,
                  labels: _labels,
                  isSaving: (state) => state == _Status.saving,
                  outcome: (effect) => switch (effect) {
                    _Saved() => const CrudEditorSuccess(),
                    _Failed() => const CrudEditorFailure(_failure),
                  },
                  onSave: () async => cubit.succeed(),
                  extraBusy: extraBusy,
                  extraDirty: extraDirty,
                  builder: (context, scope) => Column(
                    children: [
                      TextFormField(
                        controller: scope.fields['name'],
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Required'
                            : null,
                      ),
                      TextFormField(controller: scope.fields['description']),
                    ],
                  ),
                ),
              );
              onResult?.call(result);
            },
            child: const Text('Open editor'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open editor'));
  await tester.pump();
  if (!extraBusy) await tester.pumpAndSettle();
}

Finder _action(AppKey key) => find.byWidgetPredicate(
  (widget) => widget is AppButton && widget.labelKey == key,
);

CrudEditorFields _fields() =>
    CrudEditorFields(initialValues: {'name': 'Alpha', 'description': ''});

Future<void> _disposeEditor(
  WidgetTester tester,
  CrudEditorFields fields,
  _EditorCubit cubit,
) async {
  await tester.pumpWidget(const SizedBox.shrink());
  fields.dispose();
  await cubit.close();
}

void main() {
  setUpAll(() => useTranslations(const Locale('en')));

  testWidgets('success closes with true', (tester) async {
    final cubit = _EditorCubit();
    final fields = _fields();
    bool? result;
    await _open(
      tester,
      cubit: cubit,
      fields: fields,
      onResult: (value) => result = value,
    );
    await tester.enterText(find.byType(TextFormField).first, 'Beta');
    await tester.tap(_action(_save));
    await tester.pumpAndSettle();
    expect(result, isTrue);
    expect(find.byType(AppFormDialog), findsNothing);
    await _disposeEditor(tester, fields, cubit);
  });

  testWidgets('onSave runs only after Form validation', (tester) async {
    final cubit = _EditorCubit();
    final fields = _fields();
    await _open(tester, cubit: cubit, fields: fields);
    await tester.enterText(find.byType(TextFormField).first, '');
    await tester.tap(_action(_save));
    await tester.pumpAndSettle();
    expect(find.byType(AppFormDialog), findsOneWidget);
    expect(cubit.state, _Status.idle);
    await tester.enterText(find.byType(TextFormField).first, 'Valid');
    await tester.tap(_action(_save));
    await tester.pumpAndSettle();
    expect(find.byType(AppFormDialog), findsNothing);
    await _disposeEditor(tester, fields, cubit);
  });

  testWidgets('failure displays message and remains open', (tester) async {
    final cubit = _EditorCubit();
    final fields = _fields();
    await _open(tester, cubit: cubit, fields: fields);
    cubit.fail();
    await tester.pumpAndSettle();
    expect(find.text(_failure.en), findsOneWidget);
    expect(find.byType(AppFormDialog), findsOneWidget);
    await _disposeEditor(tester, fields, cubit);
  });

  testWidgets('trimmed dirty comparison ignores whitespace', (tester) async {
    final cubit = _EditorCubit();
    final fields = _fields();
    bool? result;
    await _open(
      tester,
      cubit: cubit,
      fields: fields,
      onResult: (value) => result = value,
    );
    await tester.enterText(find.byType(TextFormField).first, ' Alpha ');
    await tester.tap(_action(_cancel));
    await tester.pumpAndSettle();
    expect(find.text(TemplateKeys.unsavedChanges.en), findsNothing);
    expect(result, isFalse);
    await _disposeEditor(tester, fields, cubit);
  });

  testWidgets('busy and extraBusy disable save', (tester) async {
    final cubit = _EditorCubit();
    final fields = _fields();
    await _open(tester, cubit: cubit, fields: fields);
    cubit.setBusy();
    await tester.pump(const Duration(milliseconds: 100));
    final busySave = tester.widget<AppButton>(_action(_save));
    expect(busySave.isLoading, isTrue);
    expect(busySave.onPressed, isNull);
    await _disposeEditor(tester, fields, cubit);

    final secondCubit = _EditorCubit();
    final secondFields = _fields();
    await _open(
      tester,
      cubit: secondCubit,
      fields: secondFields,
      extraBusy: true,
    );
    final extraBusySave = tester.widget<AppButton>(_action(_save));
    expect(extraBusySave.isLoading, isTrue);
    expect(extraBusySave.onPressed, isNull);
    await _disposeEditor(tester, secondFields, secondCubit);
  });

  testWidgets('extraDirty uses AppFormDialog unsaved guard', (tester) async {
    final cubit = _EditorCubit();
    final fields = _fields();
    await _open(tester, cubit: cubit, fields: fields, extraDirty: true);
    await tester.tap(_action(_cancel));
    await tester.pumpAndSettle();
    expect(find.text(TemplateKeys.unsavedChanges.en), findsOneWidget);
    await _disposeEditor(tester, fields, cubit);
  });

  testWidgets('280px, 1.5 text scale and RTL have no layout exception', (
    tester,
  ) async {
    setScreenSize(tester, const Size(280, 720));
    final cubit = _EditorCubit();
    final fields = _fields();
    await tester.pumpWidget(
      buildTestApp(
        direction: TextDirection.rtl,
        textScale: 1.5,
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showAppFormDialog<void>(
                context,
                (_) => CrudEditorDialog<_EditorCubit, _Status, _Effect>(
                  cubit: cubit,
                  fields: fields,
                  mode: CrudEditorMode.duplicate,
                  labels: _labels,
                  isSaving: (state) => state == _Status.saving,
                  outcome: (_) => const CrudEditorSuccess(),
                  onSave: () async {},
                  builder: (context, scope) =>
                      TextFormField(controller: scope.fields['name']),
                ),
              ),
              child: const Text('Open editor'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open editor'));
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsOneWidget);
    expect(tester.takeException(), isNull);
    await _disposeEditor(tester, fields, cubit);
  });
}
